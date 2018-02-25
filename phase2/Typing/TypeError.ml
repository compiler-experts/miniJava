open AST

(* please add exception in alphabet order *)
exception ArgumentAlreadyExists of string
exception ArgumentTypeNotExiste
exception ArgumentTypeNotMatch of string
exception AttributeAlreadyExists of string
exception ClassAlreadyExists of string
exception ConstructorAlreadyExists of string
exception DuplicateLocalVariable of string
exception IncompatibleTypes of string
exception InvalidMethodDeclaration of string
exception MethodAlreadyExists of string
exception UnknownVariable of string
exception UnknownClass of string
exception UnknownMethod of string
exception UnknowActualType of string
exception WrongTypePrefixOperation of string * string
exception WrongTypePostfixOperation of string
exception WrongInvokedArgumentsLength of string
exception WrongTypesAssignOperation of Type.t option * Type.t option
exception WrongTypesOperation of Type.t option * Type.t option