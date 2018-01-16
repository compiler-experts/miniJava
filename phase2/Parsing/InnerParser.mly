%{
    open AST
    open Type

    let rec listOfNames_form_exp = function
      | { edesc = Name(id) } ->	[id]
      | { edesc = Attr(o,id) } -> (listOfNames_form_exp o)@[id]

    let rec listOfTypes_form_exp = function
      | { edesc = Name(id) } ->	Ref (Type.mk_type [] id)
      | { edesc = Attr(o,id) } -> Ref (Type.mk_type (listOfNames_form_exp o) id)
      | { edesc = Array(e,el) } -> Array(listOfTypes_form_exp e,List.length el)
      | e -> failwith ("bug listOfTypes_form_exp("^(string_of_expression e)^")")
%}

(**************
 * The tokens *
 **************)
	  
  (* Operators *)
%token OP_MUL OP_DIV OP_MOD OP_ADD OP_SUB
%token OP_AND OP_OR OP_XOR OP_NOT
%token OP_CAND OP_COR OP_COND
%token OP_GT OP_LT OP_GE OP_LE OP_EQ OP_NE
%token OP_SHL OP_SHR OP_SHRR
%token OP_BNOT
%token OP_INC OP_DEC

(* Assignment Operators *)
%token ASSIGN
%token ASS_MUL ASS_DIV ASS_MOD ASS_ADD ASS_SUB
%token ASS_SHL ASS_SHR ASS_SHRR ASS_AND ASS_XOR ASS_OR

(* Separators *)
%token LPAREN RPAREN 

(* Literal values *)
%token <string> INT_LIT
%token <string> FLOAT_LIT
%token <string> STRING
%token <char option> CHAR_LIT


(********************************
 * Priorities and associativity *
 ********************************)
%left OP_OR OP_COR
%left OP_XOR
%left OP_AND OP_CAND
%left OP_EQ OP_NE
%right OP_COND COLON
%left OP_GT OP_LT OP_GE OP_LE INSTANCEOF
%left OP_SHL OP_SHR OP_SHRR
%right ASSIGN ASS_MUL ASS_DIV ASS_MOD ASS_ADD ASS_SUB ASS_SHL ASS_SHR ASS_SHRR ASS_AND ASS_XOR ASS_OR
%right SUB_UN
%right CAST
%left OP_ADD OP_SUB
%left OP_MUL OP_DIV OP_MOD
%right OP_NOT OP_BNOT INC_UN DEC_UN
%left OP_INC OP_DEC
%left LPAREN
%left DOT

%type <AST.statement list> block
%type <AST.expression> variableInitializer
%type <AST.expression> expression
%%
(*************
 * The rules *
 *************)

%public block:
  |  bsl=body(blockStatement* ) { bsl }

blockStatement:
  | variableModifier t=aType vdl=separated_nonempty_list(COMMA,variableDeclarator) SEMI {
	VarDecl (List.map (fun (id,init) -> t, id, init) vdl)
    }
  | b=block {
	Block b
    }
  | SEMI {
	Nop
      }
  | WHILE LPAREN e=expression RPAREN b=blockStatement {
	While (e,b)
    }
  | FOR LPAREN i=forInit SEMI e=expression? SEMI u=separated_list(COMMA,expression) RPAREN b=blockStatement {
	For (i,e,u,b)
    }
  | IF LPAREN e=expression RPAREN b=blockStatement {
	If (e,b,None)
    }
  | IF LPAREN e=expression RPAREN b1=blockStatement ELSE b2=blockStatement {
	If (e,b1,Some b2)
    }
  | RETURN e=expression? SEMI {
	Return (e)
    }
  | THROW e=expression SEMI {
	Throw (e)
    }
  | TRY b1=block c=catch* FINALLY b2=block {
	Try (b1,c,b2)
    }
  | TRY b1=block c=catch+ {
	Try (b1,c,[])
    }
  | SYNCHRONIZED LPAREN expression RPAREN block { Nop }
  | SWITCH  LPAREN expression RPAREN body(switchStatement* ) { Nop }
  | DO b=blockStatement WHILE LPAREN e=expression RPAREN SEMI { Nop }
  | IDENTIFIER COLON blockStatement { Nop }
  | ASSERT expression COLON expression SEMI { Nop }
  | ASSERT expression SEMI { Nop }
  | BREAK IDENTIFIER ? SEMI { Nop }
  | c = classDeclaration { Nop }
  | e=expression0 SEMI {
	match e with
	| `Exp e -> Expr e
	| `Decl e -> e
    }
  | p = primitiveType l = list(pair(LBRACKET,RBRACKET)) vdl=separated_nonempty_list(COMMA,variableDeclarator) SEMI {
	let t = if List.length l > 0 then Array(Primitive p,List.length l) else Primitive p in
	VarDecl (List.map (fun (id,init) -> t, id, init) vdl)
    }

switchStatement:
  | switchLabel list(blockStatement) { }
switchLabel:
  | CASE expression COLON { }
  | DEFAULT COLON { }
	    
expression0:
  | e=expression { `Exp e }
  | o=expression vdl=separated_nonempty_list(COMMA,variableDeclarator)  { 
      let t = listOfTypes_form_exp o in
      `Decl (VarDecl (List.map (fun (id,init) -> t, id, init) vdl))
    }
		  
%inline catch:
  | CATCH LPAREN p=formalParameter RPAREN b=block { p,b }

forInit:
  | { [] }
  | variableModifier? t=aType vdl=separated_nonempty_list(COMMA,variableDeclarator) { List.map (fun (id,init) -> Some t, id, init) vdl }
  | variableModifier? vdl=separated_nonempty_list(COMMA,variableDeclarator2) { List.map (fun (id,init) -> None , id, init) vdl }
%inline variableModifier: FINAL { }

	      
%public %inline variableDeclarator:
  | id=IDENTIFIER list(pair(LBRACKET,RBRACKET)) init=option(preceded(ASSIGN,variableInitializer)) { id, init }

%public %inline variableDeclarator2:
  | id=IDENTIFIER init=option(preceded(ASSIGN,variableInitializer)) { id, init }

variableInitializer:
  | e = expression { e }
  | e = arrayInitializer { e }

variableInitializers:
  | (* rien *) { [] }
  | e = variableInitializer l = variableInitializerRest { e :: l }

variableInitializerRest:
  | (* rien *) { [] }
  | COMMA { [] }
  | COMMA e = variableInitializer l = variableInitializerRest { e :: l }

arrayInitializer:
  | l=body(variableInitializers) { { edesc = ArrayInit l } }

expression:
  | LPAREN e=expression RPAREN { e }
  | op=prefix_op e=expression { { edesc = Pre(op,e) } }
  | OP_SUB e=expression %prec SUB_UN { { edesc = Pre(Op_neg,e) } }
  | OP_INC e=expression %prec INC_UN { { edesc = Pre(Op_incr,e) } }
  | OP_DEC e=expression %prec DEC_UN { { edesc = Pre(Op_decr,e) } }
  | e=expression op=postfix_op { { edesc = Post(e,op) } }
  | e1=expression op=assign_op e2=expression { { edesc = AssignExp(e1,op,e2) } }
  | e1=expression OP_COND e2=expression COLON e3=expression { { edesc = CondOp(e1,e2,e3) } }
  | e1=expression op=infix_op e2=expression { { edesc = Op(e1,op,e2) } }
  | e=expression INSTANCEOF t=typeExpr { { edesc = Instanceof(e,t) } }
  | LPAREN e1=expression RPAREN e2=expression %prec CAST {
      match e1.edesc with
      | Op _  | Cast _ | Call _ -> (match e2.edesc with
		 | Pre(Op_neg,e) -> { edesc = Op(e1,Op_sub,e) }
		 | _ -> print_endline("CAST( "^(string_of_expression e1)^" ) "^(string_of_expression e2)) ; $syntaxerror)
      | New _ | NewArray _ | If _ | Val _ | AssignExp _ | Post _ | Pre _ | CondOp _ | ArrayInit _
      | ClassOf _ | Instanceof _ | VoidClass ->
         print_endline("CAST( "^(string_of_expression e1)^" ) "^(string_of_expression e2)) ; $syntaxerror
      | Attr(e,s) -> { edesc = Cast(Ref(Type.mk_type (listOfNames_form_exp e) s),e2) }
      | Array({ edesc = Name n },tabs) -> { edesc = Cast(Type.mk_array (List.length tabs) (Ref(Type.mk_type [] n)),e2) }
      | Array({ edesc = Attr(e,s) },tabs) -> { edesc = Cast(Type.mk_array (List.length tabs) (Ref(Type.mk_type (listOfNames_form_exp e) s)),e2) }
      | Name n -> { edesc = Cast(Ref(Type.mk_type [] n),e2) }
      | Type t -> { edesc = Cast(t,e2) }
      | _ -> print_endline("CAST( "^(string_of_expression e1)^" ) "^(string_of_expression e2)) ; $syntaxerror}
  | LPAREN t=primitiveType l=list(pair(LBRACKET,RBRACKET)) RPAREN e=expression %prec CAST {
      let t = match List.length l with
	| 0 -> Primitive t
	| n -> Array(Primitive t,n) in
      { edesc = Cast(t,e) }
    }
  | o=expression LPAREN params=separated_list(COMMA,expression) RPAREN {
      match o with
      | { edesc = Name(id) } ->	{ edesc = Call(None,id,params) }
      | { edesc = Attr(o,id) } -> { edesc = Call(Some o,id,params) } }
  | o=expression DOT n=name  { { edesc = Attr(o,n) } }
  | o=expression DOT CLASS  { { edesc = Attr(o,"class") } }
  | o=expression DOT NEW id=qualifiedName LPAREN params=separated_list(COMMA,expression) RPAREN option(body(classContent* )) {
      match o with
      | { edesc = Name(n) } -> { edesc = New(Some n,id,params) } }
  | VOID DOT CLASS  { { edesc = VoidClass } }
  | NEW id=qualifiedName LPAREN params=separated_list(COMMA,expression) RPAREN option(body(classContent* )) { { edesc = New(None,id,params) } }
  | NEW id=qualifiedName tab=nonempty_list(delimited(LBRACKET,expression ?,RBRACKET)) init=arrayInitializer?  { { edesc = NewArray(Ref(Type.extract_type id),tab,init) } }
  | NEW t=primitiveType tab=nonempty_list(delimited(LBRACKET,expression ?,RBRACKET)) init=arrayInitializer? { { edesc = NewArray(Primitive t,tab,init) } }
  | e=expressionSansBracket tab=nonempty_list(delimited(LBRACKET,expression ?,RBRACKET)) {
      { edesc = Array(e,tab) }
    }
  | l=literal { { edesc = Val(l) } }
  | id=name { { edesc = Name(id) } }
  | t=primitiveType l=list(pair(LBRACKET,RBRACKET)) DOT CLASS {
      let t = match List.length l with
	| 0 -> Primitive t
	| n -> Array(Primitive t,n) in
      { edesc = ClassOf(t) }
    }

expressionSansBracket:
  | LPAREN e=expression RPAREN { e }
  | id=name { { edesc = Name(id) } }
  | o=expression DOT n=name  { { edesc = Attr(o,n) } }
  | o=expression LPAREN params=separated_list(COMMA,expression) RPAREN {
      match o with
      | { edesc = Name(id) } ->	{ edesc = Call(None,id,params) }
      | { edesc = Attr(o,id) } -> { edesc = Call(Some o,id,params) }
    }

typeExpr:
  | id=IDENTIFIER { Ref(Type.mk_type [] id) }
  | id=IDENTIFIER l=nonempty_list(pair(LBRACKET,RBRACKET)) { Array(Ref(Type.mk_type [] id),List.length l) }
  | t=primitiveType l=nonempty_list(pair(LBRACKET,RBRACKET)) { Array(Primitive t,List.length l) }


%inline qualifiedName: l = separated_nonempty_list(DOT, name) { l }

%inline prefix_op:
  | OP_NOT { Op_not }
  | OP_BNOT { Op_bnot }
						  
%inline postfix_op:
  | OP_INC { Incr }
  | OP_DEC { Decr }
    
%inline name:
  | THIS { "this" }
  | SUPER { "super" }
  | id=IDENTIFIER { id }
						  
%inline assign_op:
  | ASSIGN   { Assign   }
  | ASS_ADD  { Ass_add  }
  | ASS_SUB  { Ass_sub  }
  | ASS_MUL  { Ass_mul  }
  | ASS_DIV  { Ass_div  }
  | ASS_MOD  { Ass_mod  }
  | ASS_SHL  { Ass_shl  }
  | ASS_SHR  { Ass_shr  }
  | ASS_SHRR { Ass_shrr }
  | ASS_AND  { Ass_and  }
  | ASS_XOR  { Ass_xor  }
  | ASS_OR   { Ass_or   }

%inline infix_op:
  | OP_COR  { Op_cor  }
  | OP_CAND { Op_cand }
  | OP_OR   { Op_or   }
  | OP_AND  { Op_and  }
  | OP_XOR  { Op_xor  }
  | OP_EQ   { Op_eq   }
  | OP_NE   { Op_ne   }
  | OP_GT   { Op_gt   }
  | OP_LT   { Op_lt   }
  | OP_GE   { Op_ge   }
  | OP_LE   { Op_le   }
  | OP_SHL  { Op_shl  }
  | OP_SHR  { Op_shr  }
  | OP_SHRR { Op_shrr }
  | OP_ADD  { Op_add  }
  | OP_SUB  { Op_sub  }
  | OP_MUL  { Op_mul  }
  | OP_DIV  { Op_div  }
  | OP_MOD  { Op_mod  }

%inline literal:
  | i = INT_LIT { AST.Int i }
  | f = FLOAT_LIT { AST.Float f }
  | c = CHAR_LIT { AST.Char c }
  | s = STRING { String s }
  | TRUE { AST.Boolean true}
  | FALSE { AST.Boolean false }
  | NULL { Null }



