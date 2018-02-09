open AST

type func_info = {
  ftype: Type.t;
  fargs: argument list
}

(* class definition environment *)
type class_env = {
  attributes : (string, Type.t) Hashtbl.t;
  constructors : (string, func_info) Hashtbl.t;
  methods : (string, func_info) Hashtbl.t;
  parent : Type.ref_type;
}

(* add to class environment *)
let add_to_env class_env t =
  match t.info with
  | Class c -> 
    if (Hashtbl.mem class_env t.id) <> true
    then (Hashtbl.add class_env t.id
      { attributes = (Hashtbl.create 17);
        constructors = (Hashtbl.create 17);
        methods = (Hashtbl.create 17);
        parent = c.cparent })
  | Inter -> ()

let typing ast = 
  let class_env = Hashtbl.create 17 in 
  List.iter (add_to_env class_env) ast.type_list;