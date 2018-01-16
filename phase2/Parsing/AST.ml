type argument = {
    final : bool;
    vararg : bool;
    ptype : Type.t;
    pident : string;
  }
    
type value = 
  | String of string
  | Int of string
  | Float of string
  | Char of char option
  | Null
  | Boolean of bool

type postfix_op =
  | Incr
  | Decr

type prefix_op =
  | Op_not
  | Op_neg
  | Op_incr
  | Op_decr
  | Op_bnot
  | Op_plus
    
type assign_op =
  | Assign  
  | Ass_add 
  | Ass_sub 
  | Ass_mul 
  | Ass_div 
  | Ass_mod 
  | Ass_shl 
  | Ass_shr 
  | Ass_shrr
  | Ass_and 
  | Ass_xor 
  | Ass_or  

type infix_op =
  | Op_cor  
  | Op_cand 
  | Op_or   
  | Op_and  
  | Op_xor  
  | Op_eq   
  | Op_ne   
  | Op_gt   
  | Op_lt   
  | Op_ge   
  | Op_le   
  | Op_shl  
  | Op_shr  
  | Op_shrr 
  | Op_add  
  | Op_sub  
  | Op_mul  
  | Op_div  
  | Op_mod  

type expression_desc = 
  | New of string option * string list * expression list
  | NewArray of Type.t * (expression option) list * expression option
  | Call of expression option * string * expression list
  | Attr of expression * string
  | If of expression * expression * expression
  | Val of value
  | Name of string
  | ArrayInit of expression list
  | Array of expression * (expression option) list
  | AssignExp of expression * assign_op * expression
  | Post of expression * postfix_op
  | Pre of prefix_op * expression
  | Op of expression * infix_op * expression
  | CondOp of expression * expression * expression
  | Cast of Type.t * expression
  | Type of Type.t
  | ClassOf of Type.t
  | Instanceof of expression * Type.t
  | VoidClass

and expression = 
    {
      edesc : expression_desc;
(*      eloc : Location.t;
      mutable etype : Type.t option;*)
    }

type switchLabel =
  | CstExpr of expression
  | Default

type modifier =
  | Abstract 
  | Public   
  | Protected
  | Private  
  | Static   
  | Final    
  | Strictfp
  | Transient 
  | Volatile 
  | Synchronized 
  | Native 

type astattribute = {
      mutable amodifiers : modifier list;
      aname : string;
      atype : Type.t;
      adefault : expression option;
      (*      aloc : Location.t;*)
    }
      



type qualified_name = string list

type statement =
  | VarDecl of (Type.t * string * expression option) list
  | Block of statement list
  | Nop
  | While of expression * statement
  | For of (Type.t option * string * expression option) list * expression option * expression list * statement
  | If of expression * statement * statement option
  | Return of expression option
  | Throw of expression
  | Try of statement list * (argument * statement list) list * statement list
  | Expr of expression

type astmethod = {
    mutable mmodifiers : modifier list;
    mname : string;
    mreturntype : Type.t;
    margstype : argument list;
    mthrows : Type.ref_type list;
    mbody : statement list;
    (*      mloc : Location.t;*)
  }
type astconst = {
    mutable cmodifiers : modifier list;
    cname : string;
    cargstype : argument list;
    cthrows : Type.ref_type list;
    cbody : statement list;
    (*      mloc : Location.t;*)
  }

and astclass = {
    cparent : Type.ref_type;
    cattributes : astattribute list;
    cinits : initial list;
    cconsts : astconst list;
    cmethods : astmethod list;
    ctypes : asttype list;
    cloc : Location.t;
  }

and type_info =
  | Class of astclass
  | Inter
		 
and initial = {
    static : bool ;
    block : statement list
  }

and asttype =
  {
    mutable modifiers : modifier list;
    id : string;
    info : type_info;
  }

type t = {
    package : qualified_name option;
    type_list : asttype list;
  }




let string_of_value = function
  | String s -> "\""^s^"\""
  | Boolean b -> string_of_bool b
  | Int s -> s
  | Float f -> f
  | Char(Some c) -> String.make 1 c
  | Char(None) -> "à"
  | Null -> "null"
	      
let string_of_assign_op = function
  | Assign  -> "="
  | Ass_add -> "+="
  | Ass_sub -> "-="
  | Ass_mul -> "*="
  | Ass_div -> "/="
  | Ass_mod -> "%="
  | Ass_shl -> "<<="
  | Ass_shr -> ">>="
  | Ass_shrr-> ">>>="
  | Ass_and -> "&="
  | Ass_xor -> "^="
  | Ass_or  -> "|="

let string_of_infix_op = function
  | Op_cor   -> "||"
  | Op_cand  -> "&&"
  | Op_or    -> "|"
  | Op_and   -> "&"
  | Op_xor   -> "^"
  | Op_eq    -> "=="
  | Op_ne    -> "!="
  | Op_gt    -> ">"
  | Op_lt    -> "<"
  | Op_ge    -> ">="
  | Op_le    -> "<="
  | Op_shl   -> "<<"
  | Op_shr   -> ">>"
  | Op_shrr  -> ">>>"
  | Op_add   -> "+"
  | Op_sub   -> "-"
  | Op_mul   -> "*"
  | Op_div   -> "/"
  | Op_mod   -> "%"

let string_of_prefix_op = function
  | Op_not -> "!"
  | Op_neg -> "-"
  | Op_incr -> "++"
  | Op_decr -> "--"
  | Op_bnot -> "~"
  | Op_plus -> "+"

		  
let rec string_of_expression_desc = function
  | New(None,n,al) -> 
      "new "^(String.concat "." n)^"("^
      (String.concat "," (List.map string_of_expression al))^
      ")"
  | New(Some n1,n2,al) -> 
      n1^".new "^(String.concat "." n2)^"("^
      (String.concat "," (List.map string_of_expression al))^
      ")"
  | If(c,e1,e2) -> 
      "if "^(string_of_expression c)^" { "^
      (string_of_expression e1)^" } else { "^(string_of_expression e2)^" }"
  | Call(r,m,al) ->
     (match r with
      | Some r -> (string_of_expression r)^"."
      | None -> "")^
       m^"("^
      (String.concat "," (List.map string_of_expression al))^
	")"
  | Attr(r,a) ->
      (string_of_expression r)^
      "."^a
  | Val v -> string_of_value v
  | Name s -> s
  | AssignExp(e1,op,e2) ->
      (string_of_expression e1)^(string_of_assign_op op)^(string_of_expression e2)
  | Op(e1,op,e2) ->
      (string_of_expression e1)^(string_of_infix_op op)^(string_of_expression e2)
  | CondOp(e1,e2,e3) ->
     (string_of_expression e1)^"?"^(string_of_expression e2)^":"^(string_of_expression e3)
  | Array(e,el) ->
     (string_of_expression e)^(ListII.concat_map "" (function | None -> "[]" | Some e -> "["^(string_of_expression e)^"]") el)
  | ArrayInit el ->
     "{"^(ListII.concat_map "," string_of_expression el)^"}"
  | Cast(t,e) ->
      "("^(Type.stringOf t)^") "^(string_of_expression e)
  | Post(e,Incr) -> (string_of_expression e)^"++"
  | Post(e,Decr) -> (string_of_expression e)^"--"
  | Pre(op,e) -> (string_of_prefix_op op)^(string_of_expression e)
  | Type t -> Type.stringOf t
  | ClassOf t -> Type.stringOf t
  | Instanceof(e,t) -> (string_of_expression e)^" instanceof "^(Type.stringOf t)
  | VoidClass -> "void.class"
  | NewArray(t, args,target) ->
     (match target with
     | None -> ""
     | Some e -> (string_of_expression e)^".")^
     (Type.stringOf t)^
       (ListII.concat_map "" (function None -> "[]" | Some e -> "["^(string_of_expression e)^"]") args)
       
and string_of_expression e = 
  let s = string_of_expression_desc e.edesc in
  s(*
    match e.etype with
      | None -> s
      | Some t -> "("^s^" : "^(Type.stringOf t)^")"*)

let print_attribute tab a =
  print_string tab;
  print_string ((Type.stringOf a.atype)^" "^a.aname);
  (match a.adefault with
    | None -> ()
    | Some e -> print_string(" = "^(string_of_expression e)));
  print_endline ";"

let stringOf_arg a =
  (if a.final then "final " else "")^
    (Type.stringOf a.ptype)^
      (if a.vararg then "..." else "")^
	" "^a.pident

let stringOf_modifier = function
  | Abstract  -> "abstract" 
  | Public    -> "public"   
  | Protected -> "protected"
  | Private   -> "private"  
  | Static    -> "static"   
  | Final     -> "final"    
  | Strictfp  -> "strictfp" 
  | Transient    -> "transient"   
  | Volatile     -> "volatile"    
  | Synchronized -> "synchronized"
  | Native       -> "native"      

let stringOf_sl = function
  | CstExpr e -> "case "^(string_of_expression e)
  | Default -> "default"
		      
let rec print_switchBody tab switch_label_list stm_list =
     List.iter (fun c -> print_endline(tab^(stringOf_sl c)^":")) switch_label_list;
     List.iter (print_statement (tab^"\t")) stm_list

and print_statement tab = function
  | VarDecl dl ->
     List.iter (fun (t,id,init) ->
		print_string(tab^(Type.stringOf t)^" "^id);
		(match init with
		| None -> ()
		| Some e -> print_string (" "^(string_of_expression e)));
		print_endline ";"
	       ) dl
  | Block b ->
     print_endline(tab^"{");
     List.iter (print_statement (tab^"  ")) b;
     print_endline(tab^"}")
  | Nop -> print_endline(tab^";")
  | Expr e -> print_endline(tab^(string_of_expression e)^";")
  | Return None -> print_endline(tab^"return;")
  | Return Some(e) -> print_endline(tab^"return "^(string_of_expression e)^";")
  | Throw e -> print_endline(tab^"throw "^(string_of_expression e)^";")
  | While(e,s) ->
     print_endline(tab^"while ("^(string_of_expression e)^") {");
     print_statement (tab^"  ") s;
     print_endline(tab^"}")
  | If(e,s,None) ->
     print_endline(tab^"if ("^(string_of_expression e)^") {");
     print_statement (tab^"  ") s;
     print_endline(tab^"}")
  | If(e,s1,Some s2) ->
     print_endline(tab^"if ("^(string_of_expression e)^") {");
     print_statement (tab^"  ") s1;
     print_endline(tab^"} else {");
     print_statement (tab^"  ") s2;
     print_endline(tab^"}")
  | For(fil,eo,el,s) ->
     print_string(tab^"for (");
     List.iter (fun (t,s,eo) ->
		(match t with
		 | None -> ()
		 | Some t -> print_string ((Type.stringOf t)^" "));
		print_string(s);
		(match eo with
		| None -> ()
		| Some e -> print_string (" "^(string_of_expression e)))) fil;
     print_string ";";
     (match eo with
      | None -> ()
      | Some e -> print_string (" "^(string_of_expression e)));
     print_string ";";
     print_string(ListII.concat_map "," string_of_expression el);
     print_endline ") {";
     print_statement (tab^"  ") s;
     print_endline(tab^"}")
  | Try(body,catch,finally) ->
     print_endline(tab^"try {");
     List.iter (print_statement (tab^"  ")) body;
     List.iter (fun (a,sl) ->
		print_endline(tab^"} catch ("^(stringOf_arg a)^")");
		List.iter (print_statement (tab^"  ")) sl) catch;
     (if finally != [] then
	begin
	  print_endline(tab^"} finally {");
	  List.iter (print_statement (tab^"  ")) finally
	end);
     print_endline(tab^"}");
   
and print_method tab m =
  print_string tab;
  print_string((Type.stringOf m.mreturntype)^" "^m.mname^"(");
  print_string(ListII.concat_map "," stringOf_arg m.margstype);
  print_string(")");
  print_string(" "^ListII.concat_map "," Type.stringOf_ref m.mthrows);
  print_endline(" {");
  List.iter (print_statement (tab^"  ")) m.mbody;
  print_endline(tab^"}")

and print_const tab c =
  print_string (tab^c.cname^"(");
  print_string(ListII.concat_map "," stringOf_arg c.cargstype);
  print_endline(") {");
  List.iter (print_statement (tab^"  ")) c.cbody;
  print_endline(tab^"}")

and print_class tab c =
  print_endline(" extends "^(Type.stringOf_ref c.cparent)^" {");
  List.iter (print_attribute (tab^"  ")) c.cattributes;
  List.iter (print_const (tab^"  ")) c.cconsts;
  List.iter (print_method (tab^"  ")) c.cmethods;
  print_endline(tab^"}")

and print_type tab t =
  if t.modifiers != [] then
    print_string (tab^(ListII.concat_map " " stringOf_modifier t.modifiers)^" ");
  print_string ("class "^t.id);
  (match t.info with
   | Class c -> print_class tab c
   | Inter -> ())
  
let print_package p =
  print_string "package ";
  print_endline (String.concat "." p)
	       
let print_program p =
  (match p.package with
  | None -> ()
  | Some pack -> print_package pack );
  List.iter (fun t -> print_type "" t; print_newline()) p.type_list
