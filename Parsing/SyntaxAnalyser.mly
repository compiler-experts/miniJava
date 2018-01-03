/* Headers */
%{
  open Expression
%}

/* Tokens */
/* Seperators */
%token EOF EOL LPAR RPAR SEMICOLON LBRACE RBRACE

/* Operators*/
%token EQUAL
%token PLUS MINUS TIMES DIV MOD 
%token <int> INT

/* Comments */
%token <string> ENDOFLINECOMMENT
%token <string> TRADITIONALCOMMENT

/* Identifiers*/
%token <string> LOWERIDENT UPPERIDENT

/* Keywords */
%token IF ELSE

/* Start symbols and types */
%start expression
%type < Expression.expression list> expression

/* Priority and associativity */
%right SEMICOLON
%right EQUAL
%left PLUS MINUS
%left TIMES DIV MOD
%right UMINUS UPLUS

/* End of Declarations */
%%

/* Start of Rules */
expression:

  | comment* EOF {[]}
  | e=comment_or_expression r=expression EOF
     { e::r }

comment:
  | ENDOFLINECOMMENT {}
  | TRADITIONALCOMMENT {}

comment_or_expression:
  | comment* e=expr { e }


expr:
  | e1=expr SEMICOLON 
      { Semi(e1)}
  | LPAR e=expr RPAR
      { e }
  | MINUS e=expr %prec UMINUS
      { Unop(Uminus,e) }
  | PLUS e=expr %prec UPLUS
      { Unop(Uplus,e) }
  | e1=expr o=bop e2=expr
      { Binop(o,e1,e2) }
  | i=INT
      { Int i }
  | id=LOWERIDENT
      { Var id }
  | id=LOWERIDENT EQUAL e=expr
      { Assign(id, e) }
  | IF LPAR e1=expr RPAR LBRACE e2=expr RBRACE
      { IfThen(e1, e2) }
  | IF LPAR e1=expr RPAR LBRACE e2=expr RBRACE ELSE LBRACE e3=expr RBRACE
      { IfThenElse(e1, e2, e3) }
  
%inline bop:
  | MINUS     { Bsub }
  | PLUS      { Badd }
  | TIMES     { Bmul }
  | DIV       { Bdiv }
  | MOD       { Bmod }
  
%%
