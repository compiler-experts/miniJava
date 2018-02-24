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



(*verify if a key exists in the table
exits: return true
else: return false
*)
let verifyHashtbl nameHashtbl key =
  match key with
  | _ -> Hashtbl.mem nameHashtbl key
  | "Object" -> true

let printMethodTable methodTable =
	print_endline("list of the methods ：");
	Hashtbl.iter (fun key value ->print_string("\t");print_string(key ^ " : ");print_endline(value.mname)) methodTable


let printClassDescriptor globalClassDescriptor  =
	match globalClassDescriptor with
	| ClassDescriptor cd ->
			Hashtbl.iter (fun key value ->print_string("\t\t");print_string(key ^ " : " );print_endline(value)) cd.methods

let printClassTable classTable =
	print_endline("list of the classes ：");
	Hashtbl.iter (fun key value ->print_string("\t");print_endline(key);printClassDescriptor(value)) classTable



(*
		ulity: add methods in the Hashtbl classTable
*)
let addMethodsToClassDesciptor className methods cmethod =
	if(verifyHashtbl methods  cmethod.mname) = false
	then begin
		let nameMethod = className ^ "_" ^ cmethod.mname in
		Hashtbl.add methods cmethod.mname nameMethod
	end
	else begin
		print_endline("function " ^ cmethod.mname ^ " already defined")
	end

let addToClassTable classTable className c =
  let methodsClass = Hashtbl.create 20 in
  List.iter (addMethodsToClassDesciptor className methodsClass) c.cmethods;
	Hashtbl.add classTable className (ClassDescriptor({name=className;methods=methodsClass}))

(*
	ulity: add methods in the Hashtbl methodTable
*)

let addMethodsToMethodTable className methodTable cmethod =
	let nameMethod = className ^ "_" ^ cmethod.mname in
	if(verifyHashtbl methodTable  nameMethod) = false
	then begin
		Hashtbl.add methodTable nameMethod cmethod
	end
	else begin
		print_endline("function " ^ cmethod.mname ^ " already in the method table")
	end


let addToMethodTable methodTable className c =
	List.iter (addMethodsToMethodTable className methodTable) c.cmethods





(*asttype ={  mutable modifiers : modifier list; id : string; info : type_info;}
ulity: add class and methods in the Hashtbl
*)
let compileClass methodTable classTable ast asttype =
  match asttype.info with
  | Class c -> if(verifyHashtbl classTable asttype.id) = false
                then begin  addToClassTable classTable asttype.id c;
                            addToMethodTable methodTable asttype.id c
														 end

  | Inter -> ()


(*
	methodTable: is used to find the content of a function according to the name
*)
let compileAST ast =
  let programData = { methodTable = Hashtbl.create 20; classTable = Hashtbl.create 20 } in
  List.iter (compileClass programData.methodTable programData.classTable ast) ast.type_list;
	printClassTable programData.classTable;
	printMethodTable programData.methodTable;
