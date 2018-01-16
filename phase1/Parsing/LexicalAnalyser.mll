{
  open SyntaxAnalyser

  let print_lexeme = function
    | EOF     -> print_string "EOF"
    | PLUS    -> print_string "PLUS"
    | MINUS   -> print_string "MINUS"
    | DIV     -> print_string "DIV"
    | TIMES   -> print_string "TIMES"
    | INCRE   -> print_string "INCRE"
    | DECRE   -> print_string "DECRE"
    | ASSIGN  -> print_string "ASSIGN"
    | GT      -> print_string "GT"
    | LT      -> print_string "LT"
    | NOT     -> print_string "NOT"
    | EQUAL   -> print_string "EQUAL"
    | NOTEQUAL -> print_string "NOTEQUAL"
    | LE      -> print_string "LE"
    | GE      -> print_string "GE"
    | AND     -> print_string "AND"
    | OR      -> print_string "OR"
    | INT i   -> print_string "INT("; print_int i; print_string ")"
    | ENDOFLINECOMMENT  ic -> print_string "ENDOFLINECOMMENT("; print_string ic; print_string ")"
    | TRADITIONALCOMMENT mc -> print_string "TRADITIONALCOMMENT("; print_string mc; print_string ")"
    | IF        -> print_string "IF"
    | ELSE      -> print_string "ELSE"
    | LOWERIDENT s   -> print_string "LOWERIDENT("; print_string s; print_string ")"
    | UPPERIDENT s  -> print_string "UPPERIDENT("; print_string s; print_string ")"
    | SEMICOLON   -> print_string "SEMICOLON"
    | LBRACE    -> print_string "LBRACE"
    | RBRACE    -> print_string "RBRACE"
    | LPAR      -> print_string "LPAR"
    | RPAR      -> print_string "RPAR"
    | BOOLEAN b   -> print_string "BOOL("; print_string(string_of_bool b); print_string ")"
    | NULL      -> print_string "NULL"
    | RETURN      -> print_string "RETURN"
    | COMMA     -> print_string "COMMA"
    | STRING s-> print_string "STRING("; print_string s; print_string ")";

    (*Class print*)
    | CLASS     -> print_string "CLASS"
    | NEW       -> print_string "NEW"
    | THIS      -> print_string "THIS"
    | STATIC    -> print_string "STATIC"
    | DOT       -> print_string "."
    | EXTENDS   -> print_string "EXTENDS"


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

let lower_ch = ['a'-'z']
let upper_ch = ['A'-'Z']
let digit = ['0'-'9']
let integer = digit+
let lower_id = lower_ch (lower_ch | upper_ch | digit | '_')*
let upper_id = upper_ch (lower_ch | upper_ch | digit | '_')*
(* Literal *)
let str = '"' ([^ '"'] |'\092''"')* '"'
let boolean = "true" | "false"
let space = [' ' '\009' '\012']
let newline = ('\010' | '\013' | "\013\010")
let not_newline = [^ '\n' '\r']
(* Comments *)
let endofline_comment =  "//" not_newline*
let not_star = [^ '*']
let not_star_not_slash = [^ '*' '/']
let traditional_comment =  "/*" not_star* "*"+ (not_star_not_slash not_star* "*"+)* "/"

rule nexttoken = parse
  (*Class*)
  | "class"               { CLASS }
  | "extends"             {EXTENDS}
  | "new"                 { NEW }
  | "this"                { THIS }
  | "."                   { DOT }
  | ","                   { COMMA}
  | "static"              { STATIC }

  | newline       { Location.incr_line lexbuf; nexttoken lexbuf }
  | space+        { nexttoken lexbuf }
  | endofline_comment as c   { ENDOFLINECOMMENT c}
  | traditional_comment as c { TRADITIONALCOMMENT c}
  | "if"          { IF }
  | "else"        { ELSE }
  | boolean as bl { BOOLEAN (bool_of_string bl) }
  | "null"        { NULL }
  | "return"      { RETURN }
  | str as st     { STRING st}
  | eof           { EOF }
  | "++"          { INCRE }
  | "--"          { DECRE }
  | "+"           { PLUS }
  | "-"           { MINUS }
  | "/"           { DIV }
  | "*"           { TIMES }
  | "%"           { MOD }
  | "="           { ASSIGN }
  | ">"           { GT }
  | "<"           { LT }
  | "!"           { NOT }
  | "=="          { EQUAL }
  | "!="          { NOTEQUAL }
  | "<="          { LE }
  | ">="          { GE }
  | "&&"          { AND }
  | "||"          { OR }
  | ";"           { SEMICOLON }
  | "{"           { LBRACE }
  | "}"           { RBRACE }
  | "("           { LPAR }
  | ")"           { RPAR }
  | integer as nb    { try INT (int_of_string nb) with Failure "int_of_string" -> raise_error (Illegal_int(nb)) lexbuf }
  | lower_id as str  { LOWERIDENT str }
  | upper_id as str  { UPPERIDENT str }
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
