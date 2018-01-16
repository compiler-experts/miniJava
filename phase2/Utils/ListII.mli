(* A call to concat_map sep f l produce the string concatenating the
application of f to each element of l using sep to separate each
element.  *)
val concat_map: string -> ('a -> string) -> 'a list -> string
							 
val extract_last: 'a list -> 'a * 'a list
