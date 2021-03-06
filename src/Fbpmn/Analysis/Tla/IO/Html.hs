{-# LANGUAGE QuasiQuotes #-}
module Fbpmn.Analysis.Tla.IO.Html where

import           Fbpmn.Analysis.Tla.Model
import           NeatInterpolation              ( text )
import qualified Data.Text                     as T
import           Data.Map.Strict                ( (!?) )
import qualified Data.Map.Strict               as M
                                                ( toList )

{-|
Generates an HTML+JS animation for a log.
The model file must be in the same place than the log file.
-}
writeToHTML :: FilePath -> Maybe String -> Log -> IO ()
writeToHTML p _ = writeFile p . encodeLogToHtml

genSetup :: Log -> Text
genSetup (Log _ _ Success _) =
  [text|
  <!-- success log, nothing to generate -->
  |]
genSetup (Log _ _ Failure mcex) =
  case mcex of
    Nothing -> [text||] -- not possible
    Just cex -> foldMap genForState cex

genForState :: CounterExampleState -> Text
genForState s =
  if sinfo s /= "Stuttering"
    then
      [text|
        // step $ssid
        nodes = $sns;
        edges = $ses;
        net = $snet;
        steps.push([nodes, edges, net]);
      |]
    else [text||]      
  where
    ssid = show $ sid s
    sns = maybe "new Map([])" valueToJavascript (svalue s !? "nodemarks")
    ses = maybe "new Map([])" valueToJavascript (svalue s !? "edgemarks")
    snet = maybe "undefined" valueToJavascript (svalue s !? "net")

valueToJavascript :: Value -> Text
valueToJavascript (VariableValue v) = [text|"$sv"|] where sv = show v
valueToJavascript (IntegerValue i) = show i
valueToJavascript (StringValue s) = [text|"$sv"|] where sv = toText s
valueToJavascript (TupleValue xs) = [text|[$sxs]|]
    where
      sxs = T.intercalate ", " $ valueToJavascript <$> xs
valueToJavascript (SetValue xs) = [text|[$sxs]|]
    where
      sxs = T.intercalate ", " $ valueToJavascript <$> xs
valueToJavascript (MapValue xs) = [text|new Map([$sxs])|]
    where
      sxs = T.intercalate ", " $ f <$> M.toList xs
      f (var,val) = [text|["$svar", $sval]|]
        where
          svar = toText var
          sval = valueToJavascript val
valueToJavascript (BagValue xs) = [text|new Map([$sxs])|]
    where
      sxs = T.intercalate ", " $ f <$> M.toList xs
      f (val, n) = [text|[$sval, $sn]|]
        where
          sval = valueToJavascript val
          sn = valueToJavascript n

encodeLogToHtml :: Log -> Text
encodeLogToHtml l =
  let
    model = toText $ fromMaybe "noModel" $ lmodel l
    setup = genSetup l
  in
  [text|
  <!DOCTYPE html>
  <html>
    <head>
      <meta charset="UTF-8" />
      <title>fbpmn counter-example animator</title>
      <script>
        // model
        var diagramUrl = "$model";
        // elements to highlight
        var steps = [];
        var nodes;
        var edges;
        var net;
        $setup
      </script>
      <script src="https://unpkg.com/bpmn-js@3.3.1/dist/bpmn-viewer.development.js"></script>
      <script src="https://unpkg.com/jquery@3.3.1/dist/jquery.js"></script>
  
      <style>
        html, body {
          height: 100%;
          padding: 0;
          margin: 0;
        }

        #canvas {
          height: 80%;
          padding: 0;
          margin: 0;
        }
  
        #header {
          height: 10%;
          padding: 4;
          margin: 4;
          background: rgba(0,128,0,0.8);
          color: White;
        }
  
        #network {
          font-family: Arial, Helvetica, sans-serif;
          height: 10%;
          font-size: 18px;
          background: rgba(0,128,0,0.1);
          border: 0 solid rgba(0,128,0,0.8);
          border-left-width: 4px;
          color: #333;
        }
  
        #network #title {
          text-align: left;
          font-weight: bold;
          font-size: 2vh;
        }
  
        #header #title {
          font-family: Arial, Helvetica, sans-serif;
          font-weight: bold;
          font-size: 3vh;
        }
  
        #header #step {
          font-family: Arial, Helvetica, sans-serif;
          font-weight: bold;
          font-size: 3vh;
        }
  
        .highlight-node:not(.djs-connection) .djs-visual > :nth-child(1) {
          fill: rgba(0,128,0,0.4) !important;
        }
  
        .highlight-edge:not(.djs-connection) .djs-visual > :nth-child(1) {
          stroke: rgba(0,128,0,0.8) !important;
        }
  
        .highlight-overlay {
          background-color: rgba(0,128,0,0.8) !important;
          pointer-events: none; /* no pointer events, allows clicking through onto the element */
        }
  
        .diagram-note {
          background-color:rgba(0,128,0,1) !important;
          color: White;
          border-color: Black;
          border-radius: 16px;
          font-family: Arial;
          font-size: 12px;
          padding: 2px;
          min-height: 16px;
          min-width: 16px;
          text-align: center;
        }
  
        .needs-discussion:not(.djs-connection) .djs-visual > :nth-child(1) {
          stroke: rgba(0,128,0,0.4) !important;
        }
      </style>
    </head>
    <body>
      <div id="header">
        <div id="title">&nbsp;fBPMN Counter Example Animator for $model</div>
        <div class="separator"><br/></div>
        <div id="step">step ../..</div>
      </div>
      <div id="canvas"></div>
      <div id="network">
        <div id="title">Network status</div>
        <div id="status"></div>
      </div>
      <script>
  
        // viewer instance
        var bpmnViewer = new BpmnJS({container: '#canvas'});

        // possible token positions on edges
        var token_position = {START: 1, MIDDLE: 2};

        function markNode(canvas, node) {
          try {
            canvas.addMarker(node, 'highlight-node');
          }
          catch {}
        }

        function markEdge(canvas, edge) {
          try {
            canvas.addMarker(edge, 'highlight-edge');
          }
          catch {}
        }

        function unmarkNode(canvas, node) {
          try {
            canvas.removeMarker(node, 'highlight-node');
          }
          catch {}
        }

        function unmarkEdge(canvas, edge) {
          try {
            canvas.removeMarker(edge, 'highlight-edge');
          }
          catch {}
        }

        function showTokensNode(overlays, node, qty) {
          return overlays.add(node, 'note', {
              position: {top: -8,right: 8},
              html: '<div class="diagram-note">'+qty+'</div>'
            });
        }

        function netToJSON(net) {
          return JSON.stringify([...net]);
        }
  
        function edgeBoundingBox(edge) {
          var minx,miny,maxx,maxy;
          if(edge.waypoints) {
            edge.waypoints.forEach(element => {
              var x = element.x;
              var y = element.y;
              if (x<minx || minx == undefined) { minx = x; }
              if (y<miny || miny == undefined) { miny = y; }
              if (x>maxx || maxx == undefined) { maxx = x; }
              if (y>maxy || maxy == undefined) { maxy = y; }
            });
          }
          return {minx: minx, miny: miny, maxx: maxx, maxy: maxy};
        }

        function positionTokenMiddle(edge) {
          var x,y;
          var rank;
          var bb;
          if(edge != undefined && edge.waypoints != undefined && edge.waypoints.length>=2) {
            var wps = edge.waypoints;
            if((wps.length%2)==0) { // even #wp, take middle of middle segment
              rank = Math.floor((wps.length-2)/2);
              var point1 = wps[rank];
              var point2 = wps[rank+1];
              x = Math.floor((point1.x + point2.x)/2);
              y = Math.floor((point1.y + point2.y)/2);
            } else { // odd #wp, take middle wp
              rank = Math.floor((wps.length-1)/2);
              x = wps[rank].x;
              y = wps[rank].y;
            }
            bb = edgeBoundingBox(edge);
            x -= bb.minx;
            y -= bb.miny;
          }
          return {x: x, y: y};
        }

        function positionTokenStart(ee) {
          var x,y;
          var bb;
          var wp0;
          if (ee != undefined) {
            bb = edgeBoundingBox(ee);
            wp0 = ee.waypoints[0];
            x = wp0.x - bb.minx;
            y = wp0.y - bb.miny;
          }
          return {x: x, y: y};
        }

        function showTokensEdge(registry, overlays, edge, qty, pos) {
          var ee = registry.get(edge);
          var pos;
          switch(pos) {
            case token_position.START:
                pos = positionTokenStart(ee);
                break;
            case token_position.MIDDLE:
            default:
                pos = positionTokenMiddle(ee);
          }
          return overlays.add(edge, 'note', {
              position: {top: pos.y-10, left: pos.x-10},
              html: '<div class="diagram-note">'+qty+'</div>'
            });
        }

        // should be called with
        // 0 <= prestep <= nbstep-1
        // 0 <= step <= nbstep-1
        function animate(registry,canvas,overlays,csteps,markings,prestep,step,nbsteps,pos) {
          // reset markings
          var ns = csteps[prestep][0];
          var es = csteps[prestep][1];
          if (prestep != step) {
            for(const k of ns.keys()) unmarkNode(canvas,k);
            for(const k of es.keys()) unmarkEdge(canvas,k);
            for(const id of markings) overlays.remove(id);
          }
          markings = [];
          // do new marking
          ns = csteps[step][0];
          es = csteps[step][1];
          net = csteps[step][2];
          // set
          for(const k of ns.keys()) {
            markNode(canvas,k);
          }
          for(const k of es.keys()) markNode(canvas,k);
          for (const [k,v] of ns) {
            try {
              var id = showTokensNode(overlays,k,v);
              markings.push(id);
            }
            catch {}
          }
          for (const [k,v] of es) {
            try {
              var id = showTokensEdge(registry,overlays,k,v,pos);
              markings.push(id);
            }
            catch {}
          }
          $("#network #status").html(netToJSON(net)); 
          return markings;
        }
  
        /**
          * Open diagram in our viewer instance.
          *
          * @param {String} bpmnXML diagram to display
          */
        function openDiagram(bpmnXML) {
  
          // import diagram
          bpmnViewer.importXML(bpmnXML, function(err) {
  
            if (err) {
              return console.error('could not import BPMN 2.0 diagram', err);
            }
  
            // access viewer components
            var canvas = bpmnViewer.get('canvas');
            var overlays = bpmnViewer.get('overlays');
            var registry = bpmnViewer.get('elementRegistry');
            // var moddle = bpmnViewer.get('moddle');
            // var model = bpmnViewer.getDefinitions();
  
            // zoom to fit full viewport
            canvas.zoom('fit-viewport');
  
            // animation variables
            var markings = [];
            var prestep = 0;
            var step = 0;
            var position = token_position.MIDDLE;
            nbsteps = steps.length;
            // first drawing
            markings = animate(registry,canvas,overlays,steps,markings,prestep,step,nbsteps,position);
  
            document.body.onkeyup = function(e){
              if(step < nbsteps-1 && e.keyCode == 39 && e.shiftKey == false){
                prestep = step;
                step = step+1;
                markings = animate(registry,canvas,overlays,steps,markings,prestep,step,nbsteps,position);
              }
              else if(step > 0 && e.keyCode == 37 && e.shiftKey == false) {
                prestep = step;
                step = step-1;
                markings = animate(registry,canvas,overlays,steps,markings,prestep,step,nbsteps,position);
              }
              else if(e.keyCode == 37 && e.shiftKey == true) {
                prestep = step;
                step = 0;
                markings = animate(registry,canvas,overlays,steps,markings,prestep,step,nbsteps,position);
              }
              else if(e.keyCode == 39 && e.shiftKey == true) {
                prestep = step;
                step = nbsteps-1;
                markings = animate(registry,canvas,overlays,steps,markings,prestep,step,nbsteps,position);
              }
              var title = "&nbsp;step " + (step+1) + "/" + nbsteps;
              $("#step").html(title); 
            }
  
          });
        }
  
  
        // load external diagram file via AJAX and open it
        $.get(diagramUrl, openDiagram, 'text');
      </script>
    </body>
  </html>
    |]



