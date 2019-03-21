---------------- MODULE e021MBE ----------------

EXTENDS TLC, PWSTypes

VARIABLES nodemarks, edgemarks, net

ContainRel ==
  "P_id" :> { "EndEvent_1hytbgh", "Task_06osngf", "EndEvent_112jhwq", "SubProcess_07e2e99", "BoundaryEvent_1q0fgiw", "BoundaryEvent_1fak9ar", "StartEvent_1" }
  @@ "Q_id" :> { "StartEvent_1jxrjjb", "ExclusiveGateway_0pvsvob", "ExclusiveGateway_1vvyptg", "EndEvent_1gf9mha", "Task_0ouyduq", "Task_0z3cxl5" }
  @@ "SubProcess_07e2e99" :> { "StartEvent_03bqw0j", "ExclusiveGateway_1hukmk5", "Task_1i35ppr", "Task_1kso3jk", "ExclusiveGateway_0hzcbkt", "EndEvent_0ovxd43" }

Node == {
  "P_id","Q_id","EndEvent_1hytbgh","Task_06osngf","EndEvent_112jhwq","SubProcess_07e2e99","BoundaryEvent_1q0fgiw","BoundaryEvent_1fak9ar","StartEvent_1","StartEvent_03bqw0j","ExclusiveGateway_1hukmk5","Task_1i35ppr","Task_1kso3jk","ExclusiveGateway_0hzcbkt","EndEvent_0ovxd43","StartEvent_1jxrjjb","ExclusiveGateway_0pvsvob","ExclusiveGateway_1vvyptg","EndEvent_1gf9mha","Task_0ouyduq","Task_0z3cxl5"
}

Edge == {
  "MessageFlow_01dn8b3","MessageFlow_1fv5g0n","SequenceFlow_1rnwbjb","SequenceFlow_1ag4q25","SequenceFlow_1sp2uu5","SequenceFlow_0y8q6ot","SequenceFlow_109652j","SequenceFlow_16cdiue","SequenceFlow_18dl2c1","SequenceFlow_00h8rbi","SequenceFlow_03zwnxj","SequenceFlow_0fcn4he","SequenceFlow_0e70fm8","SequenceFlow_1es2p0l","SequenceFlow_0axwuh9","SequenceFlow_06cnlpk","SequenceFlow_08qsdvs","SequenceFlow_17254s0","SequenceFlow_1xvizyy"
}

Message == { "msg1", "msg2" }

msgtype ==
      "MessageFlow_01dn8b3" :> "msg1"
  @@ "MessageFlow_1fv5g0n" :> "msg2"

source ==
   "MessageFlow_01dn8b3" :> "Task_0ouyduq"
@@ "MessageFlow_1fv5g0n" :> "Task_0z3cxl5"
@@ "SequenceFlow_1rnwbjb" :> "StartEvent_1"
@@ "SequenceFlow_1ag4q25" :> "SubProcess_07e2e99"
@@ "SequenceFlow_1sp2uu5" :> "BoundaryEvent_1q0fgiw"
@@ "SequenceFlow_0y8q6ot" :> "Task_06osngf"
@@ "SequenceFlow_109652j" :> "BoundaryEvent_1fak9ar"
@@ "SequenceFlow_16cdiue" :> "StartEvent_03bqw0j"
@@ "SequenceFlow_18dl2c1" :> "ExclusiveGateway_1hukmk5"
@@ "SequenceFlow_00h8rbi" :> "ExclusiveGateway_1hukmk5"
@@ "SequenceFlow_03zwnxj" :> "Task_1i35ppr"
@@ "SequenceFlow_0fcn4he" :> "Task_1kso3jk"
@@ "SequenceFlow_0e70fm8" :> "ExclusiveGateway_0hzcbkt"
@@ "SequenceFlow_1es2p0l" :> "StartEvent_1jxrjjb"
@@ "SequenceFlow_0axwuh9" :> "ExclusiveGateway_0pvsvob"
@@ "SequenceFlow_06cnlpk" :> "ExclusiveGateway_0pvsvob"
@@ "SequenceFlow_08qsdvs" :> "Task_0ouyduq"
@@ "SequenceFlow_17254s0" :> "Task_0z3cxl5"
@@ "SequenceFlow_1xvizyy" :> "ExclusiveGateway_1vvyptg"

target ==
   "MessageFlow_01dn8b3" :> "BoundaryEvent_1q0fgiw"
@@ "MessageFlow_1fv5g0n" :> "BoundaryEvent_1fak9ar"
@@ "SequenceFlow_1rnwbjb" :> "SubProcess_07e2e99"
@@ "SequenceFlow_1ag4q25" :> "EndEvent_1hytbgh"
@@ "SequenceFlow_1sp2uu5" :> "EndEvent_1hytbgh"
@@ "SequenceFlow_0y8q6ot" :> "EndEvent_112jhwq"
@@ "SequenceFlow_109652j" :> "Task_06osngf"
@@ "SequenceFlow_16cdiue" :> "ExclusiveGateway_1hukmk5"
@@ "SequenceFlow_18dl2c1" :> "Task_1i35ppr"
@@ "SequenceFlow_00h8rbi" :> "Task_1kso3jk"
@@ "SequenceFlow_03zwnxj" :> "ExclusiveGateway_0hzcbkt"
@@ "SequenceFlow_0fcn4he" :> "ExclusiveGateway_0hzcbkt"
@@ "SequenceFlow_0e70fm8" :> "EndEvent_0ovxd43"
@@ "SequenceFlow_1es2p0l" :> "ExclusiveGateway_0pvsvob"
@@ "SequenceFlow_0axwuh9" :> "Task_0ouyduq"
@@ "SequenceFlow_06cnlpk" :> "Task_0z3cxl5"
@@ "SequenceFlow_08qsdvs" :> "ExclusiveGateway_1vvyptg"
@@ "SequenceFlow_17254s0" :> "ExclusiveGateway_1vvyptg"
@@ "SequenceFlow_1xvizyy" :> "EndEvent_1gf9mha"

CatN ==
   "P_id" :> Process
@@ "Q_id" :> Process
@@ "EndEvent_1hytbgh" :> NoneEndEvent
@@ "Task_06osngf" :> AbstractTask
@@ "EndEvent_112jhwq" :> NoneEndEvent
@@ "SubProcess_07e2e99" :> SubProcess
@@ "BoundaryEvent_1q0fgiw" :> MessageBoundaryEvent
@@ "BoundaryEvent_1fak9ar" :> MessageBoundaryEvent
@@ "StartEvent_1" :> NoneStartEvent
@@ "StartEvent_03bqw0j" :> NoneStartEvent
@@ "ExclusiveGateway_1hukmk5" :> Parallel
@@ "Task_1i35ppr" :> AbstractTask
@@ "Task_1kso3jk" :> AbstractTask
@@ "ExclusiveGateway_0hzcbkt" :> ExclusiveOr
@@ "EndEvent_0ovxd43" :> TerminateEndEvent
@@ "StartEvent_1jxrjjb" :> NoneStartEvent
@@ "ExclusiveGateway_0pvsvob" :> ExclusiveOr
@@ "ExclusiveGateway_1vvyptg" :> ExclusiveOr
@@ "EndEvent_1gf9mha" :> NoneEndEvent
@@ "Task_0ouyduq" :> SendTask
@@ "Task_0z3cxl5" :> SendTask

CatE ==
   "MessageFlow_01dn8b3" :> MsgFlow
@@ "MessageFlow_1fv5g0n" :> MsgFlow
@@ "SequenceFlow_1rnwbjb" :> NormalSeqFlow
@@ "SequenceFlow_1ag4q25" :> NormalSeqFlow
@@ "SequenceFlow_1sp2uu5" :> NormalSeqFlow
@@ "SequenceFlow_0y8q6ot" :> NormalSeqFlow
@@ "SequenceFlow_109652j" :> NormalSeqFlow
@@ "SequenceFlow_16cdiue" :> NormalSeqFlow
@@ "SequenceFlow_18dl2c1" :> NormalSeqFlow
@@ "SequenceFlow_00h8rbi" :> NormalSeqFlow
@@ "SequenceFlow_03zwnxj" :> NormalSeqFlow
@@ "SequenceFlow_0fcn4he" :> NormalSeqFlow
@@ "SequenceFlow_0e70fm8" :> NormalSeqFlow
@@ "SequenceFlow_1es2p0l" :> NormalSeqFlow
@@ "SequenceFlow_0axwuh9" :> ConditionalSeqFlow
@@ "SequenceFlow_06cnlpk" :> DefaultSeqFlow
@@ "SequenceFlow_08qsdvs" :> NormalSeqFlow
@@ "SequenceFlow_17254s0" :> NormalSeqFlow
@@ "SequenceFlow_1xvizyy" :> NormalSeqFlow

LOCAL preEdges ==
  [ i \in {} |-> {}]
PreEdges(n,e) == preEdges[n,e]

PreNodes(n,e) == { target[ee] : ee \in preEdges[n,e] }
          \union { nn \in { source[ee] : ee \in preEdges[n,e] } : CatN[nn] \in { NoneStartEvent, MessageStartEvent } }

CABoundaries ==
   "BoundaryEvent_1q0fgiw" :> True
@@ "BoundaryEvent_1fak9ar" :> False

WF == INSTANCE PWSWellFormed
ASSUME WF!WellFormedness

INSTANCE PWSSemantics

================================================================

