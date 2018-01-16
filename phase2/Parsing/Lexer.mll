{
open Parser
open Lexing
open Error

let keyword_table = Hashtbl.create 53
let _ =
  List.iter (fun (k,d) -> Hashtbl.add keyword_table k d) 
     KeywordLexer.kw_list

		     
let ident_or_keyword id =
  try Hashtbl.find keyword_table id
  with Not_found -> IDENTIFIER id

let buff = Buffer.create 256
let buffer_string str =	Buffer.add_string buff str
let buffer_char ch    =	Buffer.add_char buff ch

let char_for_backslash = function
  | 'b' -> '\008'
  | 't' -> '\009'
  | 'n' -> '\010'
  | 'r' -> '\013'
  | 'f' -> '\012'
  | c   -> c
}

let not_newline_char = [^ '\n' '\r']
let newline = (['\n' '\r'] | "\r\n")
let blank = [' ' '\014' '\t' '\012']
let digit = ['0'-'9']
let hexdigit = digit | ['a'-'f''A'-'F']	      
let letter = ['a'-'z''A'-'Z']
let id_char = (letter | digit | '_' | '$')
let esc_char = ['b' 't' 'n' 'f' 'r' '\"' '\'' '\\' ]
let float_type = ['f' 'F' 'd' 'D']
let hex_type = ['x' 'X']
let int_type = ['l' 'L']
let exp_char = ['e' 'E']
let integer = digit+ | '0' hex_type hexdigit+
let signed_integer = ['+' '-']? integer
  
rule token = parse
  | newline                 { Location.incr_line lexbuf; token lexbuf }
  | blank +                 { token lexbuf }
  | "/*"                    { comment (Location.curr lexbuf) lexbuf; token lexbuf }
  | "//" not_newline_char*  { token lexbuf }
  | letter id_char * as id  { ident_or_keyword id }
  | '_' id_char + as id     { IDENTIFIER id }
  | '$' id_char + as id     { IDENTIFIER id }
  | "("                     { LPAREN }
  | ")"                     { RPAREN }
  | "{"                     { LBRACE }
  | "}"                     { RBRACE }
  | "["                     { LBRACKET }
  | "]"                     { RBRACKET }
  | ","                     { COMMA }
  | ";"                     { SEMI }
  | "."                     { DOT }
  | "="                     { ASSIGN }
  | "*="                    { ASS_MUL }
  | "/="                    { ASS_DIV }
  | "%="                    { ASS_MOD }
  | "+="                    { ASS_ADD }
  | "-="                    { ASS_SUB }
  | "<<="                   { ASS_SHL }
  | ">>="                   { ASS_SHR }
  | ">>>="                  { ASS_SHRR }
  | "&="                    { ASS_AND }
  | "^="                    { ASS_XOR }
  | "|="                    { ASS_OR }
  | ":"                     { COLON }
  | '+'                     { OP_ADD }
  | '-'                     { OP_SUB }
  | "++"                    { OP_INC }
  | "--"                    { OP_DEC }
  | '*'                     { OP_MUL }
  | '/'                     { OP_DIV }
  | '%'                     { OP_MOD }
  | "&"                     { OP_AND }
  | "|"                     { OP_OR }
  | "^"                     { OP_XOR }
  | "!"                     { OP_NOT }
  | "&&"                    { OP_CAND }
  | "||"                    { OP_COR }
  | "?"                     { OP_COND }
  | ">"                     { OP_GT }
  | ">="                    { OP_GE }
  | "<"                     { OP_LT }
  | "<="                    { OP_LE }
  | "=="                    { OP_EQ }
  | "!="                    { OP_NE }
  | "<<"                    { OP_SHL }
  | ">>"                    { OP_SHR }
  | ">>>"                   { OP_SHRR }
  | "~"                     { OP_BNOT }
  | "..."                   { VARARG }
  | (integer int_type?) as nb            { INT_LIT nb }
  | (integer '.' integer? (exp_char signed_integer)? float_type?) as nb   { FLOAT_LIT nb }
  | ('.' integer (exp_char signed_integer)? float_type?) as nb            { FLOAT_LIT nb }
  | (integer exp_char signed_integer float_type?) as nb                   { FLOAT_LIT nb }
  | (integer (exp_char signed_integer)? float_type) as nb                 { FLOAT_LIT nb }
  | eof                     { EOF }
  | "\'\\" esc_char as c "\'" { CHAR_LIT (Some(char_for_backslash c.[0]))  }
  | "\'" _ as c "\'"          { CHAR_LIT (Some c.[0]) }
  | "\'\\0\'"          { CHAR_LIT None }
  | "\'\\u" hexdigit hexdigit hexdigit hexdigit "\'" { CHAR_LIT None }
  | "\'\\" digit digit digit "\'" { CHAR_LIT None }
  | "\""
      { 
	Buffer.reset buff;
        let string_start = lexbuf.lex_start_p in
          string (Location.curr lexbuf) lexbuf;
          lexbuf.lex_start_p <- string_start;
          STRING (Buffer.contents buff) 
      }
  | _ as ch  { illegal_char ch (Location.curr lexbuf) }

and string start_loc = parse
  | '"'                  { () }
  | '\\' 'u' hexdigit hexdigit hexdigit hexdigit { string start_loc lexbuf }
  | "\\0" { string start_loc lexbuf }
  | '\\' digit digit digit { string start_loc lexbuf }
  | '\\' esc_char as ch  { buffer_string ch; string start_loc lexbuf }
  | '\\'                 { illegal_escape_char (Location.curr lexbuf) }
  | newline | eof        { unterminated_string start_loc }
  | _ as ch              { buffer_char ch; string start_loc lexbuf }

and comment start_loc = parse
  | "*/"    { () }
  | newline { Location.incr_line lexbuf; comment start_loc lexbuf }
  | _       { comment start_loc lexbuf }
  | eof     { unterminated_comment start_loc }

