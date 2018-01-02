type binop =
  | Badd | Bsub | Bmul | Bdiv | Bmod

type unop =
  | Uplus | Uminus

type expression =
  | Const of int
  | Var of string
  | Assign of string * expression
  | Binop of binop * expression * expression
  | Unop of unop * expression
  | Semi of expression
  | IfThen of expression * expression
  | IfThenElse of expression * expression * expression
  

exception Unbound_variable of string

let get_op_u = function
  | Uplus -> fun x -> x
  | Uminus -> fun x -> -x

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

let string_of_op_b = function
  | Badd -> "+"
  | Bsub -> "-"
  | Bmul -> "*"
  | Bdiv -> "/"
  | Bmod -> "%"


let rec string_of_expr exp =
  match exp with
  | Const c             -> string_of_int c
  | Var v               -> "Var("^v^")"
  | Binop(op, e1, e2)   -> "(" ^(string_of_expr e1)^ (string_of_op_b op) ^(string_of_expr e2)^ ")"
  | Unop(op, e)         -> "(" ^ (string_of_op_u op) ^(string_of_expr e)^ ")"
  | Assign(s,e)         ->  "Assign(" ^s^ "=" ^(string_of_expr e)^ ")"
  | Semi(e1)            ->  (string_of_expr e1)^ ";\n"
  | IfThen(e1,e2)    ->  "If("^(string_of_expr e1)^") {\n"^(string_of_expr e2 )^" })\n"
  | IfThenElse(e1,e2,e3)    ->  "If("^(string_of_expr e1)^") {\n"^(string_of_expr e2 )^" } Else {\n"^(string_of_expr e3)^" })\n"
  