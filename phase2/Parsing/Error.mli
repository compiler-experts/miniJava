(* The error type with its associated exception for the compiler *)
type t
exception Error of t * Location.t

(* print an error *)
val report_error : t -> unit

(* raise the various errors *)
val illegal_char : char -> Location.t -> 'a
val illegal_escape_char : Location.t -> 'a
val unterminated_string : Location.t -> 'a
val unterminated_comment : Location.t -> 'a
val syntax : Location.t -> 'a
