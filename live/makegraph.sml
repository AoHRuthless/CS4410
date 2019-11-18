structure MakeGraph: MAKEGRAPH =

struct

structure Flow = Flow
structure A = Assem

fun instrs2graph insns =
  let
    val control = Graph.newGraph()

    fun mkVertices(insn::insns, table, labelVertices, defs, uses, moves, labels, stack) =
        case instr
          of A.LABEL {assem, lab} =>
              mkVertices(tail, table, labelVertices, defs, uses, moves, lab::labels, stack)
           | (A.MOVE {assem, dst, src} | A.OPER {assem, src, dst, jump}) =>
              let
                val top = Graph.newNode(control)
                fun updateTable (tbl, values) =
                  Graph.Table.enter(tbl, node, values)
                val newDefs = updateTable(defs, dst::nil)
                val newUses = updateTable(uses, src::nil)
                val newTable = updateTable(table, insn)
                val newMoves = updateTable(moves, true)
                (* TODO: update labelVertices with table and mapping over labels? *)
              in mkVertices(insns, newTable, newLabelVertices, newDefs, newUses, newMoves, nil, top::stack)
              end
      | mkVertices(nil, table, labelVertices, defs, uses, moves, labels, stack) =
        (table, labelVertices, defs, uses, moves, stack)

    val empty = Graph.Table.empty
    val (table, labelVertices, def, use, ismove, stack) =
      mkVertices(insns, empty, empty, empty, empty, empty, nil, nil)

    fun mkEdges [curr, prev]::prevs =
        let
          fun jmps vertex =
            let
              val insn =
                case Graph.Table.look(insns, node)
                 of SOME i => i
                  | NONE => ErrorMsg.impossible "Vertex could not be found in instructions table"
              val jmpLabels =
                case insn
                  of A.OPER {assem, src, dst, jump = SOME labels} => labels
                   | _ => nil
            in
              (* TODO: traverse labelVertices to find jmpLabels *)
            end
        in
          (map (fn to => Graph.mk_edge {from=curr, to=to}) jmps(curr);
           (if jmps(prev) = nil then Graph.mk_edge {from=prev, to=curr});
           mkEdges(prev::prevs))
        end
  in
    (mkEdges vertices;
     (Flow.FGRAPH {control=control, def=def, use=use, ismove=ismove}, Graph.nodes control))
  end
end