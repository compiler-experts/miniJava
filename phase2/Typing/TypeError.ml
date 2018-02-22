open AST

exception ClassAlreadyExists of string
exception AttributeAlreadyExists of string
exception ArgumentAlreadyExists of string
exception DuplicateLocalVariable of string
exception IncompatibleTypes of string
exception MethodAlreadyExists of string
exception ConstructorAlreadyExists of string
exception WrongTypesAssignOperation of Type.t option * Type.t option