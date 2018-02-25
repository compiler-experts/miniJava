# The minijavac compiler

A compilation project for Thrid year students of IMT Atlantique (the former Telecom Bretagne)

The specification of the project can be found [here](https://svn.telecom-bretagne.eu/repository/ens-eleves/3a/f2b/304/minijava.pdf) (Authorization Required)

## Table of Content

- [How to clone the project](#how-to-clone-the-project)
- [The project structure](#the-project-structure)
- [How to build the compiler](#how-to-build-the-compiler)
- [How to execute the compiler](#how-to-execute-the-compiler)
- [How to test the Compiler](#how-to-test-the-compiler)
- [How to contribute to the Project](#how-to-contribute-to-the-project)
- [To do list](#to-do-list)
  * [First part: Lexical and syntactic analyzers](#first-part--lexical-and-syntactic-analyzers)
    + [Expression Todo List](#expression-todo-list)
    + [Classes Todo List](#classes-todo-list)
  * [Second part: The Type-checking and the Execution](#second-part--the-type-checking-and-the-execution)
    + [Type-checking Todo List](#type-checking-todo-list)
      - [Notes on errors that can be found during Type-checking](#notes-on-errors-that-can-be-found-during-type-checking)
      - [Errors that can not yet be found during Type-checking](#errors-that-can-not-yet-be-found-during-type-checking)
    + [Execution](#execution)
      - [1. Complilation](#1-complilation)
      - [Errors that can be found during Complilation](#errors-that-can-be-found-during-complilation)
      - [2. Execution](#2-execution)
- [Problems](#problems)
  * [Problems of Type](#problems-of-type)
  * [Problems of Execution](#problems-of-execution)

---

## How to clone the project

Using `git clone`

```sh
git clone https://redmine-df.telecom-bretagne.eu/git/f2b304_compiler_cn
```

then enter your Username and Password in the command prompt

## The project structure

The project is divided by 2 parts

- phase1: the first deliverable that contains the lexical and syntax analyzer for the language minijava
- phase2: the second deliverable that contains the type checking, compiling and executing for the language minijava based on the lexical and syntax analyzer that offered by professors

## How to build the compiler

To build or execute the compiler, plase enter one of the two deliverables, either `phase1` or `phase2`

Using `cd ./phase1` or `cd ./phase2`

Then using the shell script `build` to build the compiler

```sh
./build
```

or using `ocamlbuild` to build the compiler

```sh
ocamlbuild Main.byte
```

*Notes for contributors*
> The main file is `Main/Main.ml`, it should not be modified. It opens the given file,creates a lexing buffer, initializes the location and call the compile function of the module `Main/compile.ml`. It is this function that you should modify to call your parser.

## How to execute the compiler

Using the shell script `minijavac` to execute the compiler

```sh
./minijavac <filename>
```

or using the following command to build and then execute the compiler on the given file named `<filename>`

```sh
ocamlbuild Main.byte -- <filename>
```

> By default, the program searches for file with the extension `.java` and append it to the given filename if
it does not end with it.

## How to test the Compiler

Using the shell script `test` to test the Compiler

```sh
./test
```

it will execute `Main.byte` on all files in the directory `Evaluator`

## How to contribute to the Project

If you are a team member of the project, please review the [Guidelines for Contributing](./CONTRIBUTING.md) to this repository in order to make appropriate contributions

## To do list

### First part: Lexical and syntactic analyzers

*Deadline 15/01/2018*

#### Expression Todo List

- [x] Line Terminators
- [ ] Input Elements and Tokens
- [x] White Space
- [x] Comments
- [x] Identifiers
- [x] Keywords
    - [ ] for
    - [ ] while
    - [x] else
    - [x] if
- [x] Literals
    - [x] Int
    - [x] String
- [x] Separators
    - [x] brace
    - [x] parenthese
    - [x] dot
    - [x] comma
    - [x] semicolon
- [x] Operators
    - [x] `=` Simple Assignment Operator
    - [x] `+ - * / %` Arithmetic Operators
    - [x] `+ - ++ -- !` Unary Operators
    - [x] `== != > < <= >=` Equality and Relational Operators
    - [x] `&& ||` Conditional Operators

#### Classes Todo List

- [x] Keywords
    - [x] class
    - [x] static
    - [x] extends
    - [x] return
    - [ ] new
- [x] Classes
    - [x] Class Declaration
        - [x] simple class declaration
        - [x] simple class declaration with extends
    - [x] Field Declarations
        - [x] static Fields
        - [x] non-static Fields
    - [x] Method Declarations
        - [x] static Methods
        - [x] non-static Methods
---

### Second part: The Type-checking and the Execution

*Deadline 25/02/2018*

#### Type-checking Todo List

*note for the reviewer: [ ] denotes item that needs to do while [x] denotes item that has done*

- [x] The construction of the class definition environment. This environment contains the type of methods for each class. This phase ignores the attributes (which are not visible outside the class) and the method bodies.
    - [x] create a class definition environment type called `class_env`, it contains 4 fields as follows
        - methods: a `Hashtbl` that maps from method name to method return type and argument type
        - constructors: a `Hashtbl` that maps from constructor name to class reference type and argument type
        - attributes: a `Hashtbl` that maps from attribute name to attribute type (declared type)
        - parent: a class reference type that refers to its class
    - [x] create a `Hashtbl` that maps from class
- [ ] The second phase is concerned with verifying that the inside of classes is correct (mainly the body of methods). She will also make sure of the correction of the higher level expression.
    - [x] create 3 verification methods that verify the following aspects of the program
        - [x] `verify_methods` that checks the type of methods
            - [x] create a local definition environment type called `current_env` that contains 3 fields as follows
                - returntype: the declared return type of the method
                - variables: a `Hashtbl` that maps from local variable name to local variable declared type
                - this_class: the id of the class
                - env_type: a string that identifies the type of the local definition environment, it could be `constructor`, `method` or `attribute`, in this case, the `env_type` is `method`
            - [x] write a verification method (`verify_declared_args`) that checks the declared type of variables in the method argument list
                - [x] check if there exists Duplicate Local Variable
            - [x] write a verification method (`verify_statement`) that checks the body of the method
                - [x] check variable declaration statement
                - [x] check block of statement
                - [x] check expression
                - [x] check return statement when it's none, ex: `return;`
                - [x] check return statement when it's not none, ex: `return x;`
                - [x] check throw statement
                    -  it does check if exception type or a supertype of that exception type is mentioned in a throws clause in the declaration of the method, it should be checked in compiling
                - [x] check while statement
                - [x] check if without else statement
                - [x] check if with else statement
                - [x] check for statement
                - [x] check try statement
        - [x] `verify_constructors` that checks the type of constructors
            - same as verify_methods, except for the following minor difference
            - `returntype` in the local definition environment `current_env` is a reference to the class it belongs to
            - `env_type` in the local definition environment `current_env` is `constructor`
            - check return statement in `verify_statement` is slightly different since constructors can have `reuturn;` but not something like `return x;`
        - [x] `verify_attributes` that checks the type of attributes
            - [x] create a local definition environment type called `current_env` it contains 3 fields as following
                - returntype: since attributes have no return value, so it sets to be `Type.Void`
                - variables: a `Hashtbl` that maps from local variable name to local variable declared type
                - this_class: the id of the current class
                - env_type: which is `attribute` here
            - [x] write a verification expression (`verify_expression`) that checks the declared type of an expression
                In `verify_expression`: 
                - [x] check `New` expression type which instantiates a class
                - [x] check `NewArray` expression type which declares an array like: new int[5]
                - [x] check `Call` expression type which calls a method, here, we didn't check `this` keyword when calling a method. For the moment, it only supports the case when the class name has already existes in `class_en` hashtable.
                - [x] check `Attr` expression type which calls an attribute
                - [x] check `If` expression type
                - [x] check `Val` expression type which is the primitive type like int, string... in an expression
                - [x] check `Name` expression type which represents a variable
                - [x] check `ArrayInit` expression type which initializes an array like {1,2,3}
                - [ ] check `Array` expression type (TODO). This part has not been done for the moment
                - [x] check `AssignExp` expression type which compares an assignment operation type
                - [x] check `Post` expression type which is some post operations type, like: a++, b--...
                - [x] check `Pre` expression type which is some pre operations type, like: !a, ~b...
                - [x] cehck `Op` expression type which is some operation optype, like: ||, &&, +, -...
                - [x] check `CondOp` expression type which is conditional operation, like a ? b : c
                - [x] check `Cast` expression type
                - [x] check `Type` expression type
                - [x] check `ClassOf` expression type
                - [x] check `Instanceof` expression type
                - [x] check `VoidClass` expression 
            - [x] write an verification method (`verify_assignop_type`) that checks the declared type of an attribute match the type of the expression. It has three inputs:
                - t1: the type of an attribute
                - t2: the type of the corresponding expression of an attribute
                - op: the type of operation, here is `Type.Assign`
    - [ ] add support to `this` keyword within a class in order to do type checking like `this.a = 5;`
    - [ ] add location in exception message in order to locate errors
- [ ] add support to overload methods and constructors

##### Notes on errors that can be found during Type-checking

- ArgumentAlreadyExists
    - when found duplicated argument in constructor argument list -> ArgumentAlreadyExists("[pident of argument]")
    - when found duplicated argument in method argument list -> ArgumentAlreadyExists("[pident of argument]")
- ArgumentTypeNotExiste
    - when found the arguments in a called function don't existe a declared method
- ArgumentTypeNotMatch
    - when found the arguments in a called function don't match a declared method -> ArgumentTypeNotMatch("Arguments\' type in "^meth_name^" not match")
- AttributeAlreadyExists
    - when found duplicated attribute in class definition environment -> AttributeAlreadyExists("[aname of attribute]")
- ClassAlreadyExists
- ConstructorAlreadyExists
    - when found duplicated constructor in class definition environment -> ConstructorAlreadyExists("[cname of constructor]")
- DuplicateLocalVariable
    - when found duplcated variable in variable declaration statement (VarDecl) -> DuplicateLocalVariable("[decalred type] [variable id]")
    - when found duplcated variable in the init part of for loop statement (For(fil,eo,el,s)) -> DuplicateLocalVariable("[decalred type] [variable id]")
    - also raise this exception when found duplcated variable in variable declaration statement in the body of block, if, if else, for, while statement -> DuplicateLocalVariable("[decalred type] [variable id]")
- IncompatibleTypes
    - when constructor try to return a variable ->  ("unexpected return value")
    - when method return does not contain variable -> IncompatibleTypes("missing return value")
    - when method return type does not corresponds with the declared one -> IncompatibleTypes("missing return value")
    - when condition in if statement is not boolean ->  IncompatibleTypes("[actual type] cannot be converted to boolean")
    - when condition in if else statement is not boolean ->  IncompatibleTypes("[actual type] cannot be converted to boolean")
    - when loop condition in for statement is not boolean ->  IncompatibleTypes("[actual type] cannot be converted to boolean")
    - when loop condition in while statement is not boolean ->  IncompatibleTypes("[actual type] cannot be converted to boolean")
- InvalidMethodDeclaration
    - when method declaration does not have return type -> InvalidMethodDeclaration("return type required")
- MethodAlreadyExists
    - when found duplicated method in class definition environment -> MethodAlreadyExists("[mname of method]") 
- UnknownActualType
    - when actual type of a variable cannot be determined in variable declaration statement (VarDecl) -> UnknownActualType("[edesc] don't have type information")
    - when actual type of a variable cannot be determined in the init part of for loop statement (For(fil,eo,el,s)) -> UnknownActualType("[edesc] don't have type information")
    - when actual type of variable cannot be determined in the condition part of while loop statement (While(e,s)) -> UnknownActualType("[edesc]: unknow type in while condition")
    - when actual type of variable cannot be determined in the condition part of if statement (If(e,s,None)) -> UnknownActualType("[edesc]: unknow type in if condition")
    - when actual type of variable cannot be determined in the condition part of if else statement (If(e,s,Some s2)) -> UnknownActualType("[edesc]: unknow type in if else condition")
- UnknownVariable
    - when the variable does not existe in current environment or global environment -> UnknownVariable("[variable_name]")
- UnknownClass
- UnknownMethod
- WrongTypePrefixOperation
    - when the prefix operation type is not match -> WrongTypePrefixOperation("[operation, expr]")
- WrongTypePostfixOperation
    - when the postfix operation type is not match -> WrongTypePostfixOperation("[operation, expr]")
- WrongInvokedArgumentsLength
    - when actual and formal argument lists differ in length -> WrongInvokedArgumentsLength()
- WrongTypesAssignOperation
    - when an assignment operation type is not match -> WrongTypesAssignOperation("[expr1_type, op, expr2_type]")
- WrongTypesOperation
    - when an operation type is not match -> WrongTypesAssignOperation("[expr1_type, op, expr2_type]")

##### Errors that can not yet be found during Type-checking

- errors related to overloading
- errors related to generic types
- errors related to `this` keyword

#### Execution

Evaluation and execute by certain means

##### 1. Complilation

Construction of class descriptors table and method table.

class descriptors table :
name - classTable : (string, globalClassDescriptor) Hashtbl.t

method table :
name - methodTable : (string, astmethod) Hashtbl.t

All the contents of functions of different classes are saved in the methodTable
All the contents of classes are saved in the classTable except for the contents of functions
Here we use the name of functions and type of params to in class descriptor to find the content of function in the methodTable

functions:
- class descriptor of a class : func_name_typeOfpara1,typeOfpara2    classname_func_name_typeOfpara1,typeOfpara2
- method table of : classname_func_name_typeOfpara1,typeOfpara2      astmethod
In this way, functions that has the same name but different type of paramters are permitted in the compilation

constructors:
  name : typeOfpara1,typeOfpara2
  content: astconst
In this way, different types of constructors are permitted

Please take care that overriding are not supported in the typage. For testing the overriding, please delete the typage function first. 

##### Errors that can be found during Complilation
ParentClassNotDefined ：raised when parent class is not defined in the file
SameFunctionAlreadyDefined: raised when function of class have the same name and the same type of parameters
SameFunctionConstructorsDefined : raised when constructors of class have the same name and the same type of parameters


##### 2. Execution


## Problems

### Problems of Type

- not support method overloading
- not support generic types
- not support typing related to `this` keyword

### Problems of Execution
