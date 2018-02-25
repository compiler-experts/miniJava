open AST
open Hashtbl



type classDescriptor =
{
	pname : string;
	pattributes : astattribute list;
	name : string;
	methods : (string, string) Hashtbl.t;
	constructors : (string, astconst) Hashtbl.t;
	attributes : astattribute list
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

let stringOf_argType a =
  (if a.final then "final " else "")^
    (Type.stringOf a.ptype)^
      (if a.vararg then "..." else "")

let printMethodTable methodTable =
	print_endline("list of the methods ：");
	Hashtbl.iter (fun key value ->print_string("\t");print_string(key ^ " : ");print_endline(value.mname)) methodTable


let printConstructor c=
	print_string (c.cname^"(");
	print_string(ListII.concat_map "," stringOf_arg c.cargstype);
	print_endline(")")



let printClassDescriptor globalClassDescriptor  =
	match globalClassDescriptor with
	| ClassDescriptor cd ->
			print_string("\t\t");print_endline("functions:");Hashtbl.iter (fun key value ->print_string("\t\t\t");print_string(key ^ " : " );print_endline(value)) cd.methods;
			print_string("\t\t");print_endline("attributs:");List.iter (print_attribute("\t\t\t")) cd.attributes;
			print_string("\t\t");print_endline("pattributs:");List.iter (print_attribute("\t\t\t")) cd.pattributes;
			print_string("\t\t");print_endline("constructors:");Hashtbl.iter (fun key value ->print_string("\t\t\t");print_string(key ^ " : " );printConstructor value) cd.constructors;
			print_string("\t\t");print_endline("parent: ");print_string("\t\t\t");print_endline(cd.pname);
			print_endline("-----------------------------------------------------------------------------------------")


let printClassTable classTable =
	print_endline("list of the classes ：");
	Hashtbl.iter (fun key value ->print_string("\t");print_endline(key);printClassDescriptor(value)) classTable





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


(*
		ulity: add methods, constructors,attributes in the Hashtbl classTable
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

let addConstructorsToClassDesciptor constructorsClass constructor =
	Hashtbl.add constructorsClass (ListII.concat_map "," stringOf_argType constructor.cargstype) constructor

let addMethodsToClassDesciptorFromParent classTable methodsClass c =
	if (Hashtbl.mem classTable c.cparent.tid) = true
	then begin
		let parentClassDescriptor = Hashtbl.find classTable c.cparent.tid in
		match parentClassDescriptor with
		| ClassDescriptor cd -> Hashtbl.iter (fun key value -> if(Hashtbl.mem methodsClass key) <> true then Hashtbl.add methodsClass key value) cd.methods
	end



let getAttributesFromParent classTable c =
	if (Hashtbl.mem classTable c.cparent.tid) = true
	then begin
		let parentClassDescriptor = Hashtbl.find classTable c.cparent.tid in
		match parentClassDescriptor with
		| ClassDescriptor cd -> cd.attributes
	end
	else
		begin
		match c with
		| _ -> []
		end


let addToClassTable classTable className c =
  let methodsClass = Hashtbl.create 20 in
	let constructorsClass = Hashtbl.create 20 in
  List.iter (addMethodsToClassDesciptor className methodsClass) c.cmethods;
	List.iter (addConstructorsToClassDesciptor constructorsClass) c.cconsts;
	addMethodsToClassDesciptorFromParent classTable methodsClass c;
	getAttributesFromParent classTable c;
	let parentAttributes = getAttributesFromParent classTable c in
	Hashtbl.add classTable className (ClassDescriptor({pname=c.cparent.tid ;pattributes=parentAttributes; name=className;methods=methodsClass;attributes=c.cattributes;constructors=constructorsClass}))



(*asttype ={  mutable modifiers : modifier list; id : string; info : type_info;}
ulity: add class and methods in the Hashtbl
*)
let compileClass methodTable classTable ast asttype =
  match asttype.info with
  | Class c -> if(verifyHashtbl classTable asttype.id) = false
                then begin
									addToClassTable classTable asttype.id c;
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
