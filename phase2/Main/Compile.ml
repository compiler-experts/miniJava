open Parser

let execute lexbuf verbose =
  try
    let ast = compilationUnit Lexer.token lexbuf in
    print_endline "successfull parsing";
    if verbose then AST.print_program ast;
    print_endline "===================";
    Typing.typing ast;
    if verbose then AST.print_program ast;
    print_endline "successfull typing";
    Compilation.compileAST ast;
    print_endline "compile successfull";

  with
    | Error ->
      print_string "Syntax error: ";
      Location.print (Location.curr lexbuf)
    | Error.Error(e,l) ->
      Error.report_error e;
      Location.print l
