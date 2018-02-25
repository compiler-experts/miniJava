# The minijavac compiler

A compilation project for Thrid year students of IMT Atlantique (the former Telecom Bretagne)

The specification of the project can be found [here](https://svn.telecom-bretagne.eu/repository/ens-eleves/3a/f2b/304/minijava.pdf) (Authorization Required)

## How to clone the project

Using `git clone`

```sh
git clone https://redmine-df.telecom-bretagne.eu/git/f2b304_compiler_cn
```

then input your Username and Password in the command prompt

## The project structure

The project is divided by 2 parts

- phase1: the first delivery which contains the lexical and syntax analyzer for the language minijava
- phase2: the second delivery which contains the semantic analyzer for the language minijava based on the lexical and syntax analyzer that offered by professors

to build or execute the compiler, you should entre one of these folder, `cd ./phase1` or `cd ./phase2`

## How to build the compiler

Using the shell script `build`

```sh
./build
```

or using `ocamlbuild` to build the compiler

```sh
ocamlbuild Main.byte
```

*Notes*
> The main file is `Main/Main.ml`, it should not be modified. It opens the given file,creates a lexing buffer, initializes the location and call the compile function of the module `Main/compile.ml`. It is this function that you should modify to call your parser.


## How to execute the compiler


Using the shell script `minijavac`

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

Using the shell script `test`

```sh
./test
```

it will execute `Main.byte` on all files in the directory `Evaluator`

## How to contribute to the Project

If you are a team member of the project, please follow the [Working Standard](./WorkingStandard.md) to make appropriate contributions

## To do list

### First part: Lexical and syntactic analyzers

*Deadline 15/01/2018*

#### Expression

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

#### Classes

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

#### Type-checking

- [x] The construction of the class definition environment. This environment contains the type of methods for each class. This phase ignores the attributes (which are not visible outside the class) and the method bodies.
    - [x] create a class definition environment type called `class_env`, it contains 4 fields as follows
        - methods: a `Hashtbl` that maps from methode name to methode return type and argument type
        - constructors: a `Hashtbl` that maps from constructor name to class reference type and argument type
        - attributes: a `Hashtbl` that maps from attribute name to attribute type (declared type)
        - parent: a class reference type that refers to its class
    - [x] create a `Hashtbl` that maps from class
- [] The second phase is concerned with verifying that the inside of classes is correct (mainly the body of methods). She will also make sure of the correction of the higher level expression.
    - [x] create 3 verification methode that verifies the following aspects of the program
        - [x] `verify_methods` that checks the type of methods
            - [x] create a local definition environment type called `current_env` it contains 3 fields as follows
                - returntype: the declared return type of the methode
                - variables: a `Hashtbl` that maps from local variable name to local variable declared type
                - this_class: the id of the class
                - env_type: a string that identifies the type of the local definition environment, it could be `constructor`, `methode` or `attribute`, in this case, the `env_type` is `methode`
            - [x] write a verification methode (`verify_declared_args`) that checks the declared type of variables in the methode arguments
                - [x] check if there exists Duplicate Local Variable
            - [] write a verification methode (`verify_statement`) that checks the body of the methode
                - [x] check declared variables
                - [x] check block of statement
                - [x] check expression
                - [x] check return statement when it's none, ex: `return;`
                - [] check return statement when it's not none, ex: `return x;`
                - [] check throw statement
                - [] check while statement
                - [] check if statement when it doesn't have `else`
                - [] check if statement when it has `else`
                - [] check for statement
                - [] check try statement
        - [x] `verify_constructors` that checks the type of constructors
        - [x] `verify_attributes` that checks the type of attributes

##### Errors that can be found during Type-checking

- ArgumentAlreadyExists
- AttributeAlreadyExists
- ClassAlreadyExists
- ConstructorAlreadyExists
- DuplicateLocalVariable
- IncompatibleTypes
    - when constructor try to return a variable ->  IncompatibleTypes("unexpected return value")
    - when methode return does not contain variable -> IncompatibleTypes("missing return value")
    - when methode return type does not corresponds with the declared one -> IncompatibleTypes("missing return value")
- MethodAlreadyExists
- UnknowVariable
- WrongTypesAssignOperation
- WrongTypesOperation

##### Errors that can not yet be found during Type-checking

- errors related to overloading
- errors related to overriding

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



##### Errors that can be found during Complilation
ParentClassNotDefined ：raised when parent class is not defined in the file
SameFunctionAlreadyDefined: raised when function of class have the same name and the same type of parameters
SameFunctionConstructorsDefined : raised when constructors of class have the same name and the same type of parameters


##### 2. Execution


## Problems

### Problems of Type

### Problems of Execution
