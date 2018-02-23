open AST
open Hashtbl

type globalData =
{
  methodTable : (string, string) Hashtbl.t;
  classTable : (string, string) Hashtbl.t
}


let rec compileClass methodTable classTable ast asttype =
  match asttype.info with
  | Class c ->  print_endline("name of class: " ^ asttype.id)
  | Inter -> ()



let compileAST ast =
  let programData = { methodTable = Hashtbl.create 20; classTable = Hashtbl.create 20 } in
  List.iter (compileClass programData.methodTable programData.classTable ast) ast.type_list;
