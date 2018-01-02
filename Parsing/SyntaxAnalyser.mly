%{
  open Expression
%}
/* Seperators */
%token EOF EOL LPAR RPAR SEMICOLON

/* Operators*/
%token EQUAL
%token PLUS MINUS TIMES DIV MOD 
%token <int> INT


/* Comments */
%token <string> ENDOFLINECOMMENT
%token <string> TRADITIONALCOMMENT

/* Identifiers*/
%token <string> LOWERIDENT UPPERIDENT


%start expression
%type < Expression.expression list> expression

%right SEMICOLON
%right EQUAL
%left PLUS MINUS
%left TIMES DIV MOD
%right UMINUS UPLUS

%%

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
      { Const i }
  | id=LOWERIDENT
      { Var id }
  | id=LOWERIDENT EQUAL e=expr
      { Assign(id, e) }
  
%inline bop:
  | MINUS     { Bsub }
  | PLUS      { Badd }
  | TIMES     { Bmul }
  | DIV       { Bdiv }
  | MOD       { Bmod }
  
%%
