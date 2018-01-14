type binop =
  | Badd | Bsub | Bmul | Bdiv | Bmod
  | Bgt  | Blt  | Bge  | Ble  | Bequal | Bnotequal
  | Band | Bor

type unop =
  | Uplus | Uminus | Unot | Uincre | Udecre

type postfix =
  | Pincre | Pdecre

type expression =
  | Int of int
  | Var of string
  | Bool of bool
  | Null
  | String of string
  | Assign of string * expression
  | Binop of binop * expression * expression
  | Unop of unop * expression
  | Postop of expression * postfix
  | Semi of expression
  | IfThen of expression * expression
  | IfThenElse of expression * expression * expression
  | New of string
  | This
  | Invoke of expression * string * expression list

type param =
  | Param of string * string

type mthd =
  | Method of bool * string * string * (param list) * expression list

type attr =
  | Attr of string * string
  | AttrWithAssign of string * string * expression
  | StaticAttr of string * string
  | StaticAttrWithAssign of string * string * expression

type attr_or_method =
  | Attribute of attr
  | Method_t of mthd

type class_ =
  | Class_ of string * attr_or_method list
  | ClassWithExtends of string * string * attr_or_method list

type class_or_expr =
  | Class of class_
  | Expr of expression

exception Unbound_variable of string

let get_op_u = function
  | Uplus -> fun x -> x
  | Uminus -> fun x -> -x
  (* | Unot -> fun x -> not x *)
  | Uincre -> fun x -> x + 1
  | Udecre -> fun x -> x - 1

let string_of_op_u = function
  | Uplus -> "+"
  | Uminus -> "-"
  | Unot -> "not"
  | Uincre -> "++"
  | Udecre -> "--"

let string_of_op_p = function
  | Pincre -> "++"
  | Pdecre -> "--"

let string_of_op_b = function
  | Badd -> "+"
  | Bsub -> "-"
  | Bmul -> "*"
  | Bdiv -> "/"
  | Bmod -> "%"
  | Bgt  -> " > "
  | Blt  -> " < "
  | Bge  -> " >= "
  | Ble  -> " <= "
  | Bequal  -> " = "
  | Bnotequal  -> " != "
  | Band -> " && "
  | Bor  -> " || "

let rec string_of_expr exp =
  match exp with
  | Int c               -> "Int("^string_of_int c^")"
  | Var v               -> "Var("^v^")"
  | Bool b              -> string_of_bool b
  | Null                -> "null"
  | String s            -> "String("^s^")"
  | Binop(op, e1, e2)   -> "(" ^(string_of_expr e1)^ (string_of_op_b op) ^(string_of_expr e2)^ ")"
  | Unop(op, e)         -> "(" ^ (string_of_op_u op) ^(string_of_expr e)^ ")"
  | Postop(e, op)      -> "(" ^ (string_of_expr e) ^(string_of_op_p op)^ ")"
  | Assign(s,e)         ->  "Assign(" ^s^ "=" ^(string_of_expr e)^ ")"
  | Semi(e1)            ->  (string_of_expr e1)^ ";\n"
  | IfThen(e1,e2)    ->  "If("^(string_of_expr e1)^") {\n"^(string_of_expr e2 )^" })\n"
  | IfThenElse(e1,e2,e3)    ->  "If("^(string_of_expr e1)^") {\n"^(string_of_expr e2 )^" } Else {\n"^(string_of_expr e3)^" })\n"
  | This             -> "This(this)"
  | Invoke(e, s, l)  -> "Invoke("^(string_of_expr e)^"."^s^"("^(string_of_exprs l)^"))"

and string_of_exprs = function
  | [] -> ""
  | e::l -> string_of_expr e ^ string_of_exprs l

let rec string_of_param p = match p with
  | Param(t,id) -> t^" "^id

let rec string_of_params params = match params with
  | [] -> ""
  | (p :: l) -> string_of_param(p) ^ ", " ^ string_of_params l

let string_of_static_bool = function
  | true -> "static"
  | false -> "non-static"

let string_of_method = function
  | Method(static,s1,s2,p,e) -> "Method("^string_of_static_bool static^ " " ^s1^" "^s2^"(Params("^(string_of_params p)^")){"^(string_of_exprs e)^"})"

let string_of_attr = function
  | Attr (t, id)-> "Attr(Type=" ^t^ " Var=" ^id^ ")"
  | AttrWithAssign(t, id, e) -> "AttrWithAssign(Type=" ^t^ " Var=" ^id^ (string_of_expr e)^ ")"
  | StaticAttr (t, id)-> "Attr(Static Type=" ^t^ " Var=" ^id^ ")"
  | StaticAttrWithAssign(t, id, e) -> "AttrWithAssign(Static Type=" ^t^ " Var=" ^id^ (string_of_expr e)^ ")"

let string_of_attr_or_method = function
  | Attribute a -> string_of_attr a
  | Method_t m -> string_of_method m

let rec string_of_attrs_or_methods = function
  | [] -> ""
  | a::l -> (string_of_attr_or_method a) ^ " " ^ (string_of_attrs_or_methods l)

let string_of_class = function
  | Class_(id,am) -> "Class(" ^id^ "{" ^ (string_of_attrs_or_methods am) ^ " })"
  | ClassWithExtends(id1,id2,am) -> "ClassWithExtends(" ^id1^ " extends " ^id2^ "{" ^ (string_of_attrs_or_methods am) ^ " })"

let string_of_class_or_expr = function
  | Class c -> string_of_class c
  | Expr e -> string_of_expr e
