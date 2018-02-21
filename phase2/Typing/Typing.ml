open AST
open TypeError
open Type

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

type curr_env = {
  returntype : Type.t;
  variables: (string, Type.t) Hashtbl.t
}

(* check the type of value *)
let verify_value v =
  match v with
  | String s -> Some(Ref({ tpath = []; tid = "String" }))
  | Int i -> Some(Primitive(Int))
  | Float f -> Some(Primitive(Float))
  | Char c -> Some(Primitive(Char))
  | Null -> None
  | Boolean b -> Some(Primitive(Boolean))

(* check the type of the assignment operation *)
let verify_assignop_type t1 t2 =
  if t1 <> t2 then
    begin
      raise(TypeError.WrongTypesAssignOperation(t1, t2))
    end

(* check the type of the expressions *)
let rec verify_expression env current_env e =
  print_string(string_of_expression_desc(e.edesc));
  match e.edesc with
  | New (None,n,al) -> () (*TODO*)
  (* | NewArray (Some n1,n2,al) -> () (*TODO*) *)
  | Call (r,m,al) -> () (*TODO*)
  | Attr (r,a) -> () (*TODO*)
  | If (e1, e2, e3) -> () (*TODO*)
  | Val v ->
      e.etype <- verify_value v
  | Name s -> () (*TODO*)
  | ArrayInit el -> () (*TODO*)
  | Array (e,el) -> () (*TODO*)
  | AssignExp (e1,op,e2) -> () (*TODO*)
  | Post (e,op) -> () (*TODO*)
  | Pre (op,e) -> () (*TODO*)
  | Op (e1,op,e2) -> () (*TODO*)
  | CondOp (e1,e2,e3) -> () (*TODO*)
  | Cast (t,e) -> () (*TODO*)
  | Type t -> () (*TODO*)
  | ClassOf t-> () (*TODO*)
  | Instanceof (e1, t)-> () (*TODO*)
  | VoidClass -> () (*TODO*)


let verify_constructors env consts current_class =
  (*TODO*)
  ()

let verify_methods env current_class meths = 
  (*TODO*)
  ()

(* check the type of the attibutes *)
let verify_attributes env current_class attrs = 
  match attrs.adefault with
  | Some e ->
    let current_env = {returntype = Type.Void; variables = Hashtbl.create 1} in
    verify_expression env current_env e;
    (* Verify the assignment operation's type is coherent *)
    let mytype = Some(attrs.atype) in
    verify_assignop_type mytype e.etype 
  | None -> ()

(* check the type of the class *)
let verify_class env c current_class = 
  List.iter (verify_attributes env current_class) c.cattributes;
  List.iter (verify_methods env current_class) c.cmethods;
  List.iter (verify_constructors env current_class) c.cconsts

let verify_type class_env t = 
  match t.info with
  | Class c -> 
    let current_class = t.id in
    verify_class class_env c current_class;
  | Inter -> ()

let add_constructors env current_class consts =
  let consts_table = (Hashtbl.find env current_class).constructors in
  if (Hashtbl.mem consts_table consts.cname) <> true
  then (
    (* print_const "   " consts; *)
    Hashtbl.add consts_table consts.cname
    {ftype = Type.Ref {tpath=[]; tid=current_class}; 
     fargs = consts.cargstype }
  )
  else raise(ConstructorAlreadyExists(consts.cname))


(* check if method has alread exist in hash table *)
let add_methods env current_class meths =
  let meths_table = (Hashtbl.find env current_class).methods in
  if (Hashtbl.mem meths_table meths.mname) <> true
  then (
    (* print_method "   " meths; *)
    Hashtbl.add meths_table meths.mname
     {ftype = meths.mreturntype; 
      fargs = meths.margstype }
  )
  (*TODO: check override and overload*)
  else raise(MethodAlreadyExists(meths.mname)) 

(* check if attribute has already exist in hash table *)
let add_attributes env current_class attrs =
  let attrs_table = (Hashtbl.find env current_class).attributes in
  if (Hashtbl.mem attrs_table attrs.aname) <> true
  then (
    (* print_attribute "   " attrs; *)
    Hashtbl.add attrs_table attrs.aname attrs.atype
  )
  else raise(AttributeAlreadyExists(attrs.aname))

(* check class body*)
let add_class env c current_class =
  List.iter (add_attributes env current_class) c.cattributes;
  List.iter (add_methods env current_class) c.cmethods ;
  List.iter (add_constructors env current_class) c.cconsts 

(* add to class environment *)
let add_to_env class_env t =
  match t.info with
  | Class c -> 
    let current_class = t.id in
    if (Hashtbl.mem class_env t.id) <> true
    then (
      Hashtbl.add class_env t.id
        {attributes = (Hashtbl.create 17);
        constructors = (Hashtbl.create 17);
        methods = (Hashtbl.create 17);
        parent = c.cparent };
      add_class class_env c current_class 
    )      
    else raise(ClassAlreadyExists(t.id))
  | Inter -> ()

let typing ast = 
  let class_env = Hashtbl.create 17  in
  (*Step 1: Build the class definition environment*)
  List.iter (add_to_env class_env) ast.type_list;
  (*Step 2: Check the type of the inside of the class*)
  List.iter (verify_type class_env) ast.type_list
