module Fbpmn where

someFunc :: IO ()
someFunc = putStrLn ("fBPMN: formal tools for BPMN" :: Text)

--
-- Node types
--
data NodeType = AbstractTask
              | SendTask
              | ReceiveTask
              | SubProcess
              | XorGateway
              | OrGateway
              | AndGateway
              | NoneStartEvent
              | NoneEndEvent
  deriving (Eq)

--
-- Edge types
--
data EdgeType = NormalSequenceFlow
              | ConditionalSequenceFlow
              | DefaultSequenceFlow
              | MessageFlow
  deriving (Eq)

--
-- Messages
--
type Message = Text

--
-- Processes
--
type Process = Int

--
-- XML Ids
--
type Id = Text

--
-- Nodes
--
type Node = Id

--
-- Edges
--
type Edge = Id

--
-- BPMN Graph
--
data BpmnGraph = BpmnGraph { nodes :: [Node]
                           , edges :: [Edge]
                           , catN :: Node -> Maybe NodeType
                           , catE :: Edge -> Maybe EdgeType
                           , sourceE :: Edge -> Maybe Node
                           , targetE :: Edge -> Maybe Node
}

--
-- nodesT
--
nodesT :: BpmnGraph -> NodeType -> [Node]
nodesT g t = [ n | n <- nodes g, cat n == Just t ] where cat = catN g

--
-- nodesE
--
edgesT :: BpmnGraph -> EdgeType -> [Edge]
edgesT g t = [ e | e <- edges g, cat e == Just t ] where cat = catE g

--
-- in
--
inN :: BpmnGraph -> Node -> [Edge]
inN g n = [ e | e <- edges g, target e == Just n ] where target = targetE g


--
-- out
--
outN :: BpmnGraph -> Node -> [Edge]
outN g n = [ e | e <- edges g, source e == Just n ] where source = sourceE g

--
-- inT
--
inT :: BpmnGraph -> Node -> EdgeType -> [Edge]
inT g n t = [ e1 | e1 <- edgesT g t, e2 <- inN g n, e1 == e2]

--
-- outT
--
outT :: BpmnGraph -> Node -> EdgeType -> [Edge]
outT g n t = [ e1 | e1 <- edgesT g t, e2 <- outN g n, e1 == e2]
