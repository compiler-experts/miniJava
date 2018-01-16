open Ocamlbuild_plugin

let make_word_parser _ _ =
  let kw_list = Ocamlbuild_pack.Ocaml_utils.string_list_of_file "kw.txt" in
  let rec build_lex_yacc = function
    | [] -> [], []
    | kw :: t ->
       let rest_lex, rest_yacc = build_lex_yacc t in
       let lex = Printf.sprintf "\"%s\", %s ;" kw (String.uppercase kw) in
       let yacc = "%token "^(String.uppercase kw) in
       lex::rest_lex, yacc::rest_yacc in
  let lex_list, yacc_list = build_lex_yacc kw_list in
  let kw_str =
    "open Parser\n\n"^
      "let kw_list = [\n"^
      (String.concat "\n" lex_list)^
	"\n]\n" in
  let kwparser_str =(String.concat "\n" yacc_list)^"\n\n%%\n" in
  Seq [
      Cmd (S [ A "echo"; Quote (Sh kw_str); Sh ">"; P "KeywordLexer.ml" ]) ;
      Cmd (S [ A "echo"; Quote (Sh kwparser_str); Sh ">"; P "WordParser.mly" ])
    ]
      
let () =
  dispatch (function
    | Before_options ->
       Options.use_ocamlfind := true
    | Before_rules ->
      rule "Parser for words" ~prods: ["KeywordLexer.ml";"WordParser.mly"] ~dep: "kw.txt" make_word_parser
    | _ -> ())

