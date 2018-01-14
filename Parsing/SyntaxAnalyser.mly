/* Headers */
%{
  open Expression
%}

/* Class Keywords */
%token CLASS NEW THIS

/* Tokens */
/* Seperators */
%token EOF EOL LPAR RPAR SEMICOLON LBRACE RBRACE COMMA

/* Operators*/
%token ASSIGN
%token PLUS MINUS TIMES DIV MOD
%token INCRE DECRE NOT
%token GT LT EQUAL NOTEQUAL LE GE
%token AND OR
%token DOT

/* Literals */
%token <int> INT
%token <string> STRING
%token <bool> BOOLEAN
%token NULL

/* Comments */
%token <string> ENDOFLINECOMMENT
%token <string> TRADITIONALCOMMENT

/* Identifiers*/
%token <string> LOWERIDENT UPPERIDENT

/* Keywords */
%token IF ELSE STATIC


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


/* Start symbols and types */
%start content
%type < Expression.class_or_expr list> content

%%

/* Start of Rules */
content:
  | comment* EOF {[]}
  | c=class_or_expression r=content EOF
     { c::r }

class_or_expression:
  | e=comment_or_expression {e}
  | c=comment_or_class {c}

comment:
  | ENDOFLINECOMMENT {}
  | TRADITIONALCOMMENT {}

comment_or_expression:
  | comment* e=expr { Expr(e) }

comment_or_class:
  | comment* c=class_ { Class(c) }

class_:
  | CLASS id=UPPERIDENT LBRACE a=attributes_or_methods RBRACE
    { Class_(id,a) }

attributes_or_methods:
  | comment*  { [] }
  | a=attribute_or_method  r=attributes_or_methods { a::r }

attribute_or_method:
  | comment* a=attribute SEMICOLON { Attribute(a) }
  | comment* m=method1 { Method_t(m) }

attribute:
  | id=LOWERIDENT    {Attr(id)}
  | id=LOWERIDENT ASSIGN expr {AttrWithAssign(id)}

method1:
  | STATIC t=UPPERIDENT id=LOWERIDENT LPAR p=params RPAR LBRACE e=exprs RBRACE
      { Method(true, t, id, p, e) }
  | STATIC t=UPPERIDENT id=LOWERIDENT LPAR RPAR LBRACE e=exprs RBRACE
      { Method(true, t, id, [], e) }
  | t=UPPERIDENT id=LOWERIDENT LPAR p=params RPAR LBRACE e=exprs RBRACE
      { Method(false, t, id, p, e) }
  | t=UPPERIDENT id=LOWERIDENT LPAR RPAR LBRACE e=exprs RBRACE
      { Method(false, t, id, [], e) }

exprs:
    | {[]}
    | e = expr r=exprs {e::r}

param:
  | t=UPPERIDENT id=LOWERIDENT
      { Param(t,id) }
      
params:
  | { [] }
  | t=UPPERIDENT id=LOWERIDENT
      { [Param(t,id)] }	
  | t=UPPERIDENT id=LOWERIDENT COMMA r=param+
      { Param(t,id) :: r}
      
expr:
  | comment+ e=expr
      { e }
  | e=expr comment+
      { e }
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
  | b=BOOLEAN
      { Bool b }
  | n=NULL
      { Null }
  | s=STRING
      { String s}
  | id=LOWERIDENT
      { Var id }
  | id=LOWERIDENT ASSIGN e=expr
      { Assign(id, e) }
  | IF LPAR e1=expr RPAR LBRACE e2=expr RBRACE
      { IfThen(e1, e2) }
  | IF LPAR e1=expr RPAR LBRACE e2=expr RBRACE ELSE LBRACE e3=expr RBRACE
      { IfThenElse(e1, e2, e3) }
  | THIS { This }
  | e=expr DOT mthd=LOWERIDENT LPAR args_=args RPAR
      { Invoke(e, mthd, args_) }
  | NEW t =UPPERIDENT
    { New(t)}

args:
  | { [] }
  | e=expr { [e] }
  | e=expr COMMA res=args { e :: res}

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
