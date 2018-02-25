open AST
open TypeError
open Type

type func_info = {
  ftype: Type.t;
  fargs: argument list
}

type curr_env = {
  returntype : Type.t;
  variables: (string, Type.t) Hashtbl.t;
  this_class: string;
  env_type: string
}

(* class definition environment *)
type class_env = {
  attributes : (string, Type.t) Hashtbl.t;
  constructors : (string, func_info) Hashtbl.t;
  methods : (string, func_info) Hashtbl.t;
  parent : Type.ref_type;
}

(* auxiliary print functions *)
let print_arguments tab arguments =
  List.iter (fun a -> print_string(tab ^ AST.stringOf_arg a)) arguments

let print_class_env class_env =
  Hashtbl.iter (fun k v -> print_string("attribute " ^ k ^ Type.stringOf v ^ "\n")) class_env.attributes;
  Hashtbl.iter (fun k v -> print_string("constructor " ^ k ^ Type.stringOf v.ftype); print_arguments " " v.fargs; print_endline("")) class_env.constructors;
  Hashtbl.iter (fun k v -> print_string("methods " ^ k ^ Type.stringOf v.ftype); print_arguments " " 
  v.fargs; print_endline("")) class_env.methods;
  print_string("parent " ^ Type.stringOf_ref class_env.parent);
  print_endline ("")

let print_class_envs class_envs =
  Hashtbl.iter (fun k v -> print_string("class " ^ k ^ "\n"); print_class_env v ) class_envs;
  print_endline ("")


(* compare two arguments'type in two lists*)
let compare_args a1 a2 = 
  match a1.etype with
  | None -> raise(ArgumentTypeNotExiste)
  | Some t -> if(t <> a2.ptype) then raise(ArgumentTypeNotMatch("arguments type not match"))

(* check if the input arguments' type is coherent *)
let verify_invoke_args args const_info func_name = 
  (* chek if the length of arguments match the arguments which are defined in a constructor *)
  if(List.length args <> List.length const_info) then
    raise(WrongInvokedArgumentsLength("actual and formal argument lists differ in length"))
  else
    begin
      (* Use List.iter2 to compare to list*)
      List.iter2 compare_args args const_info
    end

(* verify declared types of variables in constructor arguments or methodes arguments *)
let verify_declared_args current_env arguments =
  if (Hashtbl.mem current_env.variables arguments.pident) <> true
  then (
    (* print_arguments "   " arguments; *)
    Hashtbl.add current_env.variables arguments.pident arguments.ptype
  )
  else raise(ArgumentAlreadyExists(arguments.pident))

(* check the type of value *)
let verify_value v =
  match v with
  | String s -> Some(Ref({ tpath = []; tid = "String" }))
  | Int i -> Some(Primitive(Int))
  | Float f -> Some(Primitive(Float))
  | Char c -> Some(Primitive(Char))
  | Null -> None
  | Boolean b -> Some(Primitive(Boolean))

let verify_name s env current_env = 
  (* first find in current_env *)
  if (Hashtbl.mem current_env.variables s) <> true then
    begin
      (* second find in global env *)
      if (Hashtbl.mem (Hashtbl.find env current_env.this_class).attributes s) <> true 
      then raise(UnknownVariable(s))
      else Some(Hashtbl.find (Hashtbl.find env current_env.this_class).attributes s)
    end
  else Some(Hashtbl.find current_env.variables s)

(* check the type of the assignment operation *)
let verify_assignop_type t1 t2 =
  if t1 <> t2 then
    begin
      raise(WrongTypesAssignOperation(t1, t2));
      match t1 with
      | Some t ->
        print_string "\n************************\n";
        print_string ((stringOf t));
        print_string "\n************************\n";
        match t2 with
        | Some t ->
          print_string "\n++++++++++++++++++++++\n";
          print_string ((stringOf t));
          print_string "\n++++++++++++++++++++++\n";
        | None -> ()
      | None -> ()
    end

(* check the type of the operation eg: ==, + *)
let verify_operation_type t1 op t2 =
  if t1 <> t2 then
    begin
      raise(WrongTypesOperation(t1, t2));
    end

(* check the type of call expression when it existe the method name, the arguments and global env *)
let verify_call_expr meth_name args env class_name = 
  let meths_table = (Hashtbl.find env class_name).methods in
  (* first check if method defines in class *)
  if(Hashtbl.mem meths_table meth_name) <> true then
    raise(UnknownMethod(meth_name))
  else
    begin
        let meth_info = Hashtbl.find meths_table meth_name in 
      try
        verify_invoke_args args meth_info.fargs class_name;
        Some(meth_info.ftype);
      with
        | ArgumentTypeNotExiste -> raise(ArgumentTypeNotExiste)
        | ArgumentTypeNotMatch s-> raise(ArgumentTypeNotMatch("Arguments\' type in "^meth_name^" not match"))
        | WrongInvokedArgumentsLength s -> raise(WrongInvokedArgumentsLength(s))
    end

(* check the type of the expressions *)
let rec verify_expression env current_env e =
  (* print_string(string_of_expression_desc(e.edesc)); *)
  match e.edesc with
  | New (None,n,al) -> 
    List.iter (verify_expression env current_env) al;
    let (lastClass, mylist) = ListII.extract_last n in
    (* first find in global env class*)
    if(Hashtbl.mem env lastClass) <> true then
      raise(UnknownClass(lastClass))
    else
      begin
        (* then check if constructor has already declared or not *)
        let consts_table = (Hashtbl.find env lastClass).constructors in
        (* when there is no constructor in global env and the arguments are null, 
        then set the expression type is the type of constructor *)
        if(Hashtbl.length consts_table = 0 && List.length al = 0) then
            e.etype <- Some(Ref({ tpath = []; tid = lastClass }))
        else
          begin
            (* check the type of arguments in the constructor *)
            let consts_info = Hashtbl.find consts_table lastClass in 
            try 
              verify_invoke_args al consts_info.fargs lastClass;
              e.etype <- Some(consts_info.ftype)
            with
              | ArgumentTypeNotExiste -> raise(ArgumentTypeNotExiste)
              | ArgumentTypeNotMatch s -> raise(ArgumentTypeNotMatch("Arguments\' type in "^lastClass^" not match"))
              | WrongInvokedArgumentsLength s -> raise(WrongInvokedArgumentsLength(s))
          end
      end
  (* | NewArray (Some n1,n2,al) -> () (*TODO*) *)
  | Call (r,m,al) ->
    (match r with
      | None -> (* when method is called without declaring class name*)
        List.iter (verify_expression env current_env) al;
        e.etype <- verify_call_expr m al env current_env.this_class
      | Some c ->
        List.iter (verify_expression env current_env) al;
        let class_name = string_of_expression(c) in
        e.etype <- verify_call_expr m al env class_name
    )
  | Attr (r,a) -> () (*TODO*)
  | If (e1, e2, e3) -> () (*TODO*)
  | Val v ->
      e.etype <- verify_value v
  | Name s -> 
      e.etype <- verify_name s env current_env
  | ArrayInit el -> () (*TODO*)
  | Array (e,el) -> () (*TODO*)
  | AssignExp (e1,op,e2) ->
    verify_expression env current_env e1;
    verify_expression env current_env e2;
    verify_assignop_type e1.etype e2.etype;
    e.etype <- e1.etype
  | Post (e1,op) ->
      verify_expression env current_env e1;
      (match op with
       | Incr  ->
          if (e1.etype <> Some(Primitive(Int)) && e1.etype <> Some(Primitive(Float))) then
            raise(WrongTypePostfixOperation(string_of_expression(e1)^"++"))
       | Decr ->
          if (e1.etype <> Some(Primitive(Int)) && e1.etype <> Some(Primitive(Float))) then
            raise(WrongTypePostfixOperation(string_of_expression(e1)^"--"))
      );
      e.etype <- e1.etype;
  | Pre (op,e1) -> 
      verify_expression env current_env e1;
      (match op with
        | Op_not -> 
          if e1.etype <> Some(Primitive(Boolean)) then
            raise(WrongTypePrefixOperation(string_of_prefix_op(op), string_of_expression(e1)))
        | Op_bnot ->
          if e1.etype <> Some(Primitive(Int)) then
            raise(WrongTypePrefixOperation(string_of_prefix_op(op), string_of_expression(e1)))
        | Op_neg | Op_incr | Op_decr | Op_plus ->
          if (e1.etype <> Some(Primitive(Int)) && e1.etype <> Some(Primitive(Float))) then
            raise(WrongTypePrefixOperation(string_of_prefix_op(op), string_of_expression(e1)))
      );
      e.etype <- e1.etype;
  | Op (e1,op,e2) -> 
      verify_expression env current_env e1;
      verify_expression env current_env e2;
      verify_operation_type e1.etype op e2.etype;
      (match op with
      | Op_cor | Op_cand | Op_eq | Op_ne | Op_gt | Op_lt | Op_ge | Op_le -> e.etype <- Some(Primitive(Boolean))
      | Op_or | Op_and | Op_xor | Op_shl | Op_shr | Op_shrr | Op_add | Op_sub | Op_mul | Op_div | Op_mod -> e.etype <- e1.etype)
  | CondOp (e1,e2,e3) -> () (*TODO*)
  | Cast (t,e) -> () (*TODO*)
  | Type t -> () (*TODO*)
  | ClassOf t-> () (*TODO*)
  | Instanceof (e1, t)-> () (*TODO*)
  | VoidClass -> () (*TODO*)

(* add a local variable to the current environment *)
let add_local_variable current_env id t =
  if (Hashtbl.mem current_env.variables id) <> true
  then Hashtbl.add current_env.variables id t
  else raise(DuplicateLocalVariable((Type.stringOf t)^" "^id))

(* check if actual type matches with declared type
  Parameters: 
    - e is of expression: the expression contains the actual type
    - t is of Type.t: the declared type
    - id if of string: the id for the variable in question
    - current_env: the local definition environment
  Function:
    - if actual type matches declared type: 
      add variable id and its type to the current_env
    - if e.type is None or type donesn't match:
      raise UnknowActualType exception and IncompatibleTypes
      exception respectively *)
let verify_actual_type_with_declared_type e t id current_env =
  let s = string_of_expression_desc e.edesc in
  match e.etype with
    | None -> raise(UnknowActualType(" "^s^" don't have type information"));
    (* check int i = 2, int j = i *)
    | Some actual_t -> (
      if actual_t <> t (*actual type not equals to declared type*)
      then raise(IncompatibleTypes((Type.stringOf actual_t)^" cannnot be converted to "^(Type.stringOf t)^" for "^id))
      else add_local_variable current_env id t)

(* check if acutal type matches with boolean
  Parameters:
    - e is of expression: the expression contains the actual type
    - err_msg if of string: the customized exception message
  Function:
    - if e.type is None or type donesn't match:
      raise UnknowActualType exception and IncompatibleTypes
      exception respectively *)
let verify_actual_type_with_boolean e err_msg =
  match e.etype with
      | None -> raise(UnknowActualType(err_msg))
      | Some actual_t -> if actual_t <> Primitive(Boolean)
        then raise(IncompatibleTypes((stringOf actual_t)^" cannot be converted to boolean"))

let rec verify_statement current_env envs statement =
  match statement with
  | VarDecl dl ->
    List.iter (fun (t,id,init) ->
      (match init with
      (* check int i;*)
      | None -> add_local_variable current_env id t
      (* check int j = 2; or int j = i;*)
      | Some e -> (verify_expression envs current_env e;
        verify_actual_type_with_declared_type e t id current_env
        )
      );
	  ) dl
  | Block b ->
    let block_env = { returntype = current_env.returntype;
      variables = Hashtbl.copy current_env.variables;
      this_class = current_env.this_class;
      env_type = current_env.env_type} in
    List.iter (verify_statement block_env envs) b
  | Nop -> () 
  | Expr e -> verify_expression envs current_env e
  (* check when the return clause is none, ex: return;*)
  | Return None -> (
    match current_env.returntype with
      | Ref(ref)-> if current_env.env_type <> "constructor" then raise(IncompatibleTypes("missing return value"))
      | Void -> ()
      | _ -> raise(IncompatibleTypes("This methode must return a result of type "^(Type.stringOf current_env.returntype)))
    )
  (* check when the return clause is not none, ex: return x;*)
  | Return Some(e) -> (verify_expression envs current_env e;
    if current_env.env_type <> "methode" then raise(IncompatibleTypes("unexpected return value"));
    match current_env.returntype, e.etype with
      | declared_t, Some(actual_t) -> if declared_t <> actual_t
        then raise(IncompatibleTypes((stringOf actual_t)^" cannot be converted to "^(stringOf declared_t)))
      | _, None -> raise(InvalidMethodDeclaration("return type required"))
    )
  | Throw e -> () (*TODO*)
  | While(e,s) -> (verify_expression envs current_env e;
    verify_actual_type_with_boolean e "unknow type in while condition");
    verify_statement current_env envs s
  | If(e,s,None) -> (verify_expression envs current_env e; 
    verify_statement current_env envs s;
    verify_actual_type_with_boolean e "unknow type in if condition")
  | If(e,s1,Some s2) -> (verify_expression envs current_env e;
    verify_statement current_env envs s1;
    verify_statement current_env envs s2;
    verify_actual_type_with_boolean e "unknow type in if else condition")
  | For(fil,eo,el,s) ->
    let for_env = { returntype = current_env.returntype;
        variables = Hashtbl.copy current_env.variables;
        this_class = current_env.this_class;
        env_type = current_env.env_type} in
    List.iter (fun (t,id,eo) ->
    (match t with
      | None -> ()
      | Some t -> (match eo with
        | None -> add_local_variable for_env id t
        | Some e -> verify_expression envs for_env e;
          verify_actual_type_with_declared_type e t id for_env
    ));
    ) fil;
    (match eo with
    | None -> ()
    | Some e -> verify_expression envs for_env e;
      verify_actual_type_with_boolean e "unknow type in for loop condition"
    );
    List.iter (verify_expression envs for_env) el;
    verify_statement for_env envs s;
  | Try(body,catch,finally) -> () (*TODO*)

(* check type for constructors  *)
let verify_constructors envs current_class consts =
  (* consts is of astconst structure *)
  (* print_endline ("=====verify_constructors======");
  print_class_env(Hashtbl.find envs current_class);
  print_endline ("=====verify_constructors======"); *)
  let current_env = {
    returntype = Type.Ref({ tpath = []; tid = consts.cname });
    variables = Hashtbl.create 17;
    this_class = current_class;
    env_type = "constructor"} in
  List.iter (verify_declared_args current_env) consts.cargstype;
  List.iter (verify_statement current_env envs) consts.cbody (*TODO: I am constructor*)

let verify_methods envs current_class meths =
  let current_env = {
    returntype = meths.mreturntype;
    variables = Hashtbl.create 17;
    this_class = current_class;
    env_type = "methode"} in
  List.iter (verify_declared_args current_env) meths.margstype;
  List.iter (verify_statement current_env envs) meths.mbody

(* check the type of the attibutes *)
let verify_attributes envs current_class attrs = 
  match attrs.adefault with
  | Some e ->
    let current_env = {
      returntype = Type.Void;
      variables = Hashtbl.create 17;
      this_class = current_class;
      env_type = "attribute"} in
    verify_expression envs current_env e;
    (* Verify the assignment operation's type is coherent *)
    let mytype = Some(attrs.atype) in
    verify_assignop_type mytype e.etype 
  | None -> ()

(* check the type of the class *)
let verify_class envs c current_class =
  List.iter (verify_attributes envs current_class) c.cattributes;
  List.iter (verify_methods envs current_class) c.cmethods;
  List.iter (verify_constructors envs current_class) c.cconsts

let verify_type class_envs t =
  match t.info with
  | Class c -> 
    let current_class = t.id in
    verify_class class_envs c current_class
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
let add_to_env class_envs t =
  match t.info with
  | Class c -> 
    let current_class = t.id in
    if (Hashtbl.mem class_envs t.id) <> true
    then (
      Hashtbl.add class_envs t.id
        {attributes = (Hashtbl.create 17);
        constructors = (Hashtbl.create 17);
        methods = (Hashtbl.create 17);
        parent = c.cparent };
      add_class class_envs c current_class
    )      
    else raise(ClassAlreadyExists(t.id))
  | Inter -> ()

let typing ast = 
  let class_envs = Hashtbl.create 17  in
  (*Step 1: Build the class definition environment*)
  List.iter (add_to_env class_envs) ast.type_list;
  (*Step 2: Check the type of the inside of the class*)
  List.iter (verify_type class_envs) ast.type_list
