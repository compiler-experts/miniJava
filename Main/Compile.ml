open LexicalAnalyser
open SyntaxAnalyser
open Expression


let print_expressions_or_classes exp = 
  (* Print the AST *)
  print_string (string_of_expr exp)

(* verbose is a boolean that you can use to switch to a verbose output (for example, to dump all the ast) *)
let execute lexbuf verbose = 
	
  try 
    (* to enable LexicalAnalyser, plase un comment this block
    print_endline ("Doing LexicalAnalyser....");
    LexicalAnalyser.examine_all lexbuf;
    print_string "\n"; *)
    print_endline ("Doing SyntaxAnalyser....");
    let exp_list = SyntaxAnalyser.expression nexttoken lexbuf in
      print_endline("Start printing AST...");
      List.iter print_expressions_or_classes exp_list;
      print_newline();
  with
    | LexicalAnalyser.Error (kind, s, e) ->
    	print_string("LexicalAnalyser error: ");
      report_error kind;
      let pos = Location.curr lexbuf in 
        Location.print pos;
      print_newline();
    | Error ->
      print_string("SyntaxAnalyser error: ");
      let pos = Location.curr lexbuf in
        Location.print pos;
    | _ -> print_string("Unknown error")      