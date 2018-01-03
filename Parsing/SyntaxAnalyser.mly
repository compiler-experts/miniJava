/* Headers */
%{
  open Expression
%}

/* Tokens */
/* Seperators */
%token EOF EOL LPAR RPAR SEMICOLON LBRACE RBRACE

/* Operators*/
%token ASSIGN
%token PLUS MINUS TIMES DIV MOD
%token INCRE DECRE NOT
%token GT LT EQUAL NOTEQUAL LE GE
%token AND OR

/* Literals */
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
%right ASSIGN
%left OR
%left AND
%left EQUAL NOTEQUAL
%left GT GE LT LE
%left PLUS MINUS
%left TIMES DIV MOD
%right UMINUS UPLUS NOT INCRE DECRE
%left PINCRE PDECRE

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
  | o=uop e=expr
      { Unop(o,e) }
  | MINUS e=expr %prec UMINUS
      { Unop(Uminus,e) }
  | PLUS e=expr %prec UPLUS
      { Unop(Uplus,e) }
  | e=expr INCRE %prec PINCRE
      { Postop(e,Pincre) }
  | e=expr DECRE %prec PDECRE
      { Postop(e,Pdecre) }
  | e1=expr o=bop e2=expr
      { Binop(o,e1,e2) }
  | i=INT
      { Int i }
  | id=LOWERIDENT
      { Var id }
  | id=LOWERIDENT ASSIGN e=expr
      { Assign(id, e) }
  | IF LPAR e1=expr RPAR LBRACE e2=expr RBRACE
      { IfThen(e1, e2) }
  | IF LPAR e1=expr RPAR LBRACE e2=expr RBRACE ELSE LBRACE e3=expr RBRACE
      { IfThenElse(e1, e2, e3) }

%inline uop:
  | NOT   {Unot}
  | INCRE {Uincre}
  | DECRE {Udecre}

%inline bop:
  | MINUS     { Bsub }
  | PLUS      { Badd }
  | TIMES     { Bmul }
  | DIV       { Bdiv }
  | MOD       { Bmod }
  | GT        { Bgt }
  | LT        { Blt }
  | GE        { Bge }
  | LE        { Ble }
  | EQUAL     { Bequal }
  | NOTEQUAL  { Bnotequal }
  | OR        { Bor }
  | AND       { Band }
  
%%
