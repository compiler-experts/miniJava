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
  

exception Unbound_variable of string

let get_op_u = function
  | Uplus -> fun x -> x
  | Uminus -> fun x -> -x
  (* | Unot -> fun x -> not x *)
  | Uincre -> fun x -> x + 1
  | Udecre -> fun x -> x - 1

let get_op_b op x y =
  match op with
  | Badd -> x + y
  | Bsub -> x - y
  | Bmul -> x * y
  | Bdiv -> x / y
  | Bmod -> x mod y

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
  