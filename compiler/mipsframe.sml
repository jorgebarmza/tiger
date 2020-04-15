signature FRAME =
sig 
    type frame
    type access
    val newFrame : {name: Temp.label,
                    formals: bool list} -> frame
    val name : frame -> Temp.label
    val formals : frame -> access list
    val allocLocal : frame -> bool -> access
end

structure MipsFrame : FRAME = struct
    (*TODO add view shift*)
    datatype access = InFrame of int | InReg of Temp.temp
    type frame = {formals: access list, shift: unit, locals: int ref, 
                  name: Temp.label}
    fun newFrame{name=name,formals=formals} = 
        let fun locateFormals 0 = [InFrame 0]
            |   locateFormals n = InFrame(n)::locateFormals(n-1)
        in {formals=locateFormals(length formals) , shift=(), locals= ref 0, 
            name=name}
        end
    fun name ({name=name,...} : frame) =  name
    fun formals ({formals=formals,...} : frame) =  formals
    fun allocLocal ({locals=locals,...} : frame) esc = 
        (locals := !locals + 1; 
         if esc then InReg(Temp.newtemp()) else InFrame(~ (!locals)))
end

structure Frame : FRAME = MipsFrame