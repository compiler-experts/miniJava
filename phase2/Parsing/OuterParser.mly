%{
    open AST
    open Type

    let rec separate = function
      | [] -> [], [], [], [], []
      | `Initializer(i) :: t -> let atts, inits, meths, consts, types = separate t in atts, i::inits, meths, consts, types
      | `AttList(al) :: t -> let atts, inits, meths, consts, types = separate t in al@atts, inits, meths, consts, types
      | `Meth(m) :: t -> let atts, inits, meths, consts, types = separate t in atts, inits, m::meths, consts, types
      | `Const(c) :: t -> let atts, inits, meths, consts, types = separate t in atts, inits, meths, c::consts, types
      | `Class(c) :: t -> let atts, inits, meths, consts, types = separate t in atts, inits, meths, consts, c::types
%}

/**************/
/* The tokens */
/**************/
%token EOF
	  
/* Separators */
%token LBRACE RBRACE LBRACKET RBRACKET

/* Symbols */
%token COMMA SEMI DOT COLON VARARG

 /* Identifiers */
%token <string> IDENTIFIER


/********************************/
/* Priorities and associativity */
/********************************/

/******************************/
/* Entry points of the parser */
/******************************/
%start compilationUnit
%type <AST.t> compilationUnit
%type <Type.t> aType

%%
/*************/
/* The rules */
/*************/

compilationUnit: p = program EOF { p }

program:
   p = packageDeclaration? importDeclaration* cl = classOrInterfaceDeclaration*
		       { { package = p ; type_list = cl } }

packageDeclaration: PACKAGE n = separated_nonempty_list(DOT, IDENTIFIER) SEMI { n }

importDeclaration: IMPORT STATIC? importName SEMI {}

importName:
  | id = IDENTIFIER { [id], false }
  | id = IDENTIFIER DOT rest = restName { let (list,star) = rest in id::list, star}
restName:
  | id = IDENTIFIER { [id], false }
  | OP_MUL { [], true }
  | id = IDENTIFIER DOT rest = restName { let (list,star) = rest in id::list, star}


classOrInterfaceDeclaration:
  | ml = classModifier* c = classDeclaration {
       let id, info = c in
       { modifiers = ml ; id = id ; info = info } 
    }
						   
%public %inline classModifier:
  | PUBLIC     { Public    }
  | PROTECTED  { Protected }
  | PRIVATE    { Private   }
  | ABSTRACT   { Abstract  }
  | STATIC     { Static    }
  | FINAL      { Final     }
  | STRICTFP   { Strictfp  }

%public body(X): LBRACE x=X RBRACE { x }
%public paren_comma(X): LPAREN l=separated_list(COMMA,X) RPAREN { l }
			      
%public classDeclaration:
  | CLASS id = IDENTIFIER ext = option(preceded(EXTENDS,classOrInterfaceType)) option(preceded(IMPLEMENTS,separated_list(COMMA,classOrInterfaceType))) cl=body(classContent* ) {
	let extends = match ext with
	  | None -> object_type
	  | Some t -> t in
	let atts, inits, meths, consts, types = separate cl in
	id , Class {
		       cparent = extends;
		       cattributes = atts;
		       cinits = inits;
		       cconsts = consts;
		       cmethods = meths;
		       ctypes = types;
		       cloc = Location.none;
		     }
    }
  | INTERFACE id = IDENTIFIER ext = option(preceded(EXTENDS,separated_list(COMMA,classOrInterfaceType))) cl=body(interfaceContent* ) {
	id , Inter
    }

classOrInterfaceType: l=separated_nonempty_list(DOT,IDENTIFIER)  { Type.extract_type l }
						 
%public aType:
  | t = classOrInterfaceType l = list(pair(LBRACKET,RBRACKET)) {
	if List.length l > 0 then Array(Ref t,List.length l) else Ref t
    }
  | p = primitiveType l = list(pair(LBRACKET,RBRACKET)) {
	if List.length l > 0 then Array(Primitive p,List.length l) else Primitive p
    }

%public %inline primitiveType:
  | BOOLEAN { Type.Boolean }
  | CHAR    { Type.Char   }
  | BYTE    { Type.Byte   }
  | SHORT   { Type.Short  }
  | INT     { Type.Int    }
  | LONG    { Type.Long   }
  | FLOAT   { Type.Float  }
  | DOUBLE  { Type.Double }

%public classContent:
  | s = boption(STATIC) b = block { `Initializer({ static = s ; block = b }) }
  | l = modifier* decl = memberDecl {
	match decl with
	| `AttList al -> `AttList (List.map (fun d -> { d with amodifiers = l }) al)
	| `Meth m -> `Meth { m with mmodifiers = l }
	| `Const c -> `Const { c with cmodifiers = l }
	| `Class c -> `Class { c with modifiers = l }
    }

interfaceContent:
  | l = modifier* decl = interfaceMemberDecl { }
    
memberDecl:
  | t=aType vars=separated_nonempty_list(COMMA,variableDeclarator) SEMI {
        `AttList (List.map (fun (id,init) -> { amodifiers = [] ; atype = t ; aname = id ; adefault = init }) vars)
    }
  | VOID id=IDENTIFIER pl=paren_comma(formalParameter) el=loption(throws) mb=block {
        `Meth { mmodifiers = [] ; mreturntype = Type.Void ; mname = id ; margstype=pl ; mthrows =el ; mbody=mb }
    }
  | r=aType id=IDENTIFIER pl=paren_comma(formalParameter) el=loption(throws) mb=block {
        `Meth { mmodifiers = [] ; mreturntype = r ; mname = id ; margstype=pl ; mthrows =el ; mbody=mb }
    }
  | VOID id=IDENTIFIER pl=paren_comma(formalParameter) el=loption(throws) SEMI {
        `Meth { mmodifiers = [] ; mreturntype = Type.Void ; mname = id ; margstype=pl ; mthrows =el ; mbody=[] }
    }
  | r=aType id=IDENTIFIER pl=paren_comma(formalParameter) el=loption(throws) SEMI {
        `Meth { mmodifiers = [] ; mreturntype = r ; mname = id ; margstype=pl ; mthrows =el ; mbody=[] }
    }
  | id=IDENTIFIER pl=paren_comma(formalParameter) el=loption(throws) mb=block {
        `Const { cmodifiers = [] ; cname = id ; cargstype=pl ; cthrows =el ; cbody=mb }
    }
  | c = classDeclaration {
       let id, info = c in
       `Class { modifiers = [] ; id = id ; info = info } 
    }

interfaceMemberDecl:
  | t=aType vars=separated_nonempty_list(COMMA,variableDeclarator) SEMI { }
  | VOID id=IDENTIFIER pl=paren_comma(formalParameter) el=loption(throws) SEMI { }
  | r=aType id=IDENTIFIER pl=paren_comma(formalParameter) el=loption(throws) SEMI { }
  | c = classDeclaration { }
			 
throws: THROWS el=separated_nonempty_list(COMMA,classOrInterfaceType) { el }
								   
modifier:
  | PUBLIC       { Public    }
  | PROTECTED    { Protected }
  | PRIVATE      { Private   }
  | ABSTRACT     { Abstract  }
  | STATIC       { Static    }
  | FINAL        { Final     }
  | TRANSIENT    { Transient }
  | VOLATILE     { Volatile }
  | SYNCHRONIZED { Synchronized  }
  | NATIVE       { Native  }
  | STRICTFP     { Strictfp  }

(* TODO: verify that varargs are only final *)
%public formalParameter:
  | f=boption(FINAL) t=aType va=boption(VARARG) id=IDENTIFIER l=list(pair(LBRACKET,RBRACKET)) {
	 { final = f ; vararg = va ; ptype = Type.mk_array (List.length l) t ; pident = id ; }
    }





