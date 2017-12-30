{
  open SyntaxAnalyser
  
  let print_lexeme = function
    | EOL     -> print_string "EOL"
    | EOF     -> print_string "EOF"
    | PLUS    -> print_string "PLUS"
    | MINUS   -> print_string "MINUS"
    | DIV     -> print_string "DIV"
    | TIMES   -> print_string "TIMES"
    | INT i   -> print_string "INT("; print_int i; print_string ")"
    | IDENT s -> print_string "IDENT("; print_string s; print_string ")"
    | ENDOFLINECOMMENT  ic -> print_string "ENDOFLINECOMMENT("; print_string ic; print_string ")"
    | TRADITIONALCOMMENT mc -> print_string "TRADITIONALCOMMENT("; print_string mc; print_string ")"

  open Lexing
  exception Eof
  
  type error =
    | Illegal_character of char
    | Illegal_int of string
  exception Error of error * position * position
  
  let raise_error err lexbuf =
    raise (Error(err, lexeme_start_p lexbuf, lexeme_end_p lexbuf))
  
  (* Les erreurs. *)
  let report_error = function
    | Illegal_character c ->
      print_string "Illegal character '";
      print_char c;
      print_string "' "
    | Illegal_int nb ->
      print_string "The int ";
      print_string nb;
      print_string " is illegal "
}

let letter = ['a'-'z' 'A'-'Z']
let digit = ['0'-'9']
let integer = digit+
let ident = letter (letter | digit | '_')*
let space = [' ' '\009' '\012']
let newline = ('\010' | '\013' | "\013\010")
let not_newline = [^ '\n' '\r']
let endofline_comment =  "//" not_newline*
let not_star = [^ '*']
let not_star_not_slash = [^ '*' '/']
let traditional_comment =  "/*" not_star* "*"+ (not_star_not_slash not_star* "*"+)* "/"

rule nexttoken = parse
  | newline       { Location.incr_line lexbuf; nexttoken lexbuf }
  | space+        { nexttoken lexbuf }
  | endofline_comment as c   { ENDOFLINECOMMENT c}
  | traditional_comment as c { TRADITIONALCOMMENT c}
  | eof           { EOF }
  | "+"           { PLUS } 
  | "-"           { MINUS } 
  | "/"           { DIV } 
  | "*"           { TIMES } 
  | "%"           { MOD } 
  | integer as nb    { try INT (int_of_string nb) with Failure "int_of_string" -> raise_error (Illegal_int(nb)) lexbuf }
  | ident as str  { IDENT str }
  | _ as c        { raise_error (Illegal_character(c)) lexbuf }

  {
    let rec examine_all lexbuf =
    let res = nexttoken lexbuf in
    print_lexeme res;
    print_string " ";
    match res with
    | EOF -> ()
    | _   -> examine_all lexbuf
  }
