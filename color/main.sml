structure Main = struct
  fun getsome (SOME x) = x

  fun getinstrs (Frame.PROC{body, frame}) =
    let val stms = Canon.linearize body
        val stms' = Canon.traceSchedule(Canon.basicBlocks stms)
        val instrs = List.concat(map (MipsGen.codegen frame) stms')
        val (allocated, coloring) = RegAlloc.alloc(instrs, frame)
    in
      allocated
    end
    | getinstrs (F.STRING(lab,s)) = nil

  fun printInsn insn =
    case insn
     of (Assem.OPER{assem, ...} | Assem.LABEL{assem, ...} | Assem.MOVE{assem, ...}) => print(assem)

  fun compile filename =
    let val absyn = Parse.parse filename
        val frags = (FindEscape.findEscape absyn; Semant.transProg absyn)
        val allocated = map getinstrs frags
    in
      app (fn insnList => app printInsn insnList) allocated
    end
end