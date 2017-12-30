%{
  open Expression
%}

%token EOF EOL PLUS MINUS TIMES DIV MOD LPAR RPAR
%token <int> INT
%token <string> IDENT

/* Comments */
%token <string> ENDOFLINECOMMENT
%token <string> TRADITIONALCOMMENT

%start expression
%type < Expression.expression list> expression


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
  | LPAR e=expr RPAR
      { e }
  | MINUS e=expr %prec UMINUS
      { Unop(Uminus,e)}
  | PLUS e=expr %prec UPLUS
      { Unop(Uplus,e)}
  | e1=expr o=bop e2=expr
      { Binop(o,e1,e2)}
  | id=IDENT
      { Var id }
  | i=INT
      { Const i }

%inline bop:
  | MINUS     { Bsub }
  | PLUS      { Badd }
  | TIMES     { Bmul }
  | DIV       { Bdiv }
  | MOD       { Bmod }
  
%%
