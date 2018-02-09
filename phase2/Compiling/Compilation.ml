open AST
open Hashtbl

(* This is the compilation file *)
type exe_value = 
  | VInt of int
  | VString of string
  | VAdres of int				(* l'adresse *)
  | VNull 
  | VName of string
  | VBool of bool 	
  | VAttr of string * string

let string_value value = match value with


