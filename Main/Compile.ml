open LexicalAnalyser
open SyntaxAnalyser
open Expression

(* verbose is a boolean that you can use to switch to a verbose output (for example, to dump all the ast) *)
let execute lexbuf verbose = 
	
  try 
  	print_endline ("Doing LexicalAnalyser....");
    LexicalAnalyser.examine_all lexbuf;
    print_string "\n";
    print_endline ("Doing SyntaxAnalyser....");
    (* let exp_list = SyntaxAnalyser.expression nexttoken lexbuf in
      print_endline("Start printing AST...");
      print_string (string_of_expr exp_list);
      print_newline(); *)
  with
    | LexicalAnalyser.Error (kind, s, e) ->
    	print_string("LexicalAnalyser error: ");
      report_error kind;
      let pos = Location.curr lexbuf in 
        Location.print pos;
      print_newline();
    
    | _ -> print_string("Unknown error")      