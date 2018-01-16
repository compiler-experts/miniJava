(* A located element using the Location module *)
type 'a t 

(* Create an new located element *)
val mk_elem : 'a -> Location.t -> 'a t

(* Get the element of a located element *)
val elem_of : 'a t -> 'a

(* Get the location of a located element *)
val loc_of : 'a t -> Location.t
