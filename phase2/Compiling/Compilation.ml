open AST
open Hashtbl



type classDescriptor =
{
	name : string;
	methods : (string, string) Hashtbl.t;
}

type globalClassDescriptor =
  | ClassDescriptor of classDescriptor

type globalData =
{
  methodTable : (string, astmethod) Hashtbl.t;
  classTable : (string, globalClassDescriptor) Hashtbl.t;
}

let printClassDescriptor globalClassDescriptor  =
	match globalClassDescriptor with
	| ClassDescriptor cd ->
			Hashtbl.iter (fun key value ->print_string("\t\t");print_string(key ^ " : " );print_endline(value)) cd.methods

let printClassTable classTable =
	print_endline("list of the classes ：");
	Hashtbl.iter (fun key value ->print_string("\t");print_endline(key);printClassDescriptor(value)) classTable


let addMethodsToClassDesciptor className methods cmethod =
	let nameMethod = className ^ "_" ^ cmethod.mname in
	Hashtbl.add methods cmethod.mname nameMethod


let addMethodsToMethodTable className methodTable cmethod =
	let nameMethod = className ^ "_" ^ cmethod.mname in
	Hashtbl.add methodTable nameMethod cmethod


let addToClassTable classTable className c =
  let methodsClass = Hashtbl.create 20 in
  List.iter (addMethodsToClassDesciptor className methodsClass) c.cmethods;
	Hashtbl.add classTable className (ClassDescriptor({name=className;methods=methodsClass}))


let addToMethodTable methodTable className c =
	List.iter (addMethodsToMethodTable className methodTable) c.cmethods


(*verify if a key exists in the table
exits: return true
else: return false
*)
let verifyHashtbl nameHashtbl key =
  match key with
  | _ -> Hashtbl.mem nameHashtbl key
  | "Object" -> true


(*asttype ={  mutable modifiers : modifier list; id : string; info : type_info;}*)
let compileClass methodTable classTable ast asttype =
  match asttype.info with
  | Class c -> if(verifyHashtbl classTable asttype.id) = false
                then begin  addToClassTable classTable asttype.id c;
                            addToMethodTable methodTable asttype.id c
														 end

  | Inter -> ()


let compileAST ast =
  let programData = { methodTable = Hashtbl.create 20; classTable = Hashtbl.create 20 } in
  List.iter (compileClass programData.methodTable programData.classTable ast) ast.type_list;
	printClassTable programData.classTable
