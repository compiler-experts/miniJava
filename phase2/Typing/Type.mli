type primitive =
  | Boolean
  | Char   
  | Byte   
  | Short  
  | Int    
  | Long   
  | Float  
  | Double 
      
and ref_type = {
    tpath : string list ;
    tid : string ;
  }      

type t =
  | Void
  | Array of t * int
  | Primitive of primitive
  | Ref of ref_type

(* The type of Java Object *)
val object_type: ref_type

(* function that create an array of size, if t is already an array it just increase its size *)
val mk_array : int -> t -> t

val extract_type : string list -> ref_type
val mk_type : string list -> string -> ref_type
  
(* conversions between types and string *)
val stringOf : t -> string
val stringOf_ref : ref_type -> string
