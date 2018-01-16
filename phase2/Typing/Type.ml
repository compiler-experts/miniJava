type primitive =
  | Boolean
  | Char   
  | Byte   
  | Short  
  | Int    
  | Long   
  | Float  
  | Double 

type ref_type = {
    tpath : string list ;
    tid : string ;
  }
      
type t =
  | Void
  | Array of t * int
  | Primitive of primitive
  | Ref of ref_type

let object_type = { tpath = [] ; tid = "Object" }
	     
let rec array_param = function
  | 0 -> ""
  | n -> "[]"^(array_param (n-1))

let stringOf_prim = function
  | Boolean -> "boolean"
  | Char    -> "char"   
  | Byte    -> "byte"   
  | Short   -> "short"  
  | Int     -> "int"    
  | Long    -> "long"   
  | Float   -> "float"  
  | Double  -> "double" 

(* TODO: print type arguments *)
		 
let stringOf_ref rt =
  (if (List.length rt.tpath > 0) then
    (String.concat "." rt.tpath)^"."
   else
     ""
  )^rt.tid
									  
let rec stringOf = function
  | Void -> "void"
  | Array(typ,size) -> (stringOf typ)^(array_param size)
  | Primitive prim -> stringOf_prim prim
  | Ref rt -> stringOf_ref rt

let mk_array size t =
  match size,t with
  | 0  , _           -> t
  | n1 , Array(t,n2) -> Array(t,n1+n2)
  | n  , _           -> Array(t,n)

let extract_type l =
  let id,p = ListII.extract_last l in
  { tpath = p ; tid = id }

let mk_type p id =
  { tpath = p ; tid = id }
