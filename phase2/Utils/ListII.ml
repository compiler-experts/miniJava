let concat_map sep f l = 
  let rec concat_map_rec = function
    | [] -> ""
    | [v] -> f v
    | v::t -> (f v)^sep^(concat_map_rec t)
  in
  concat_map_rec l

let extract_last l =
  let rec extract_last_rec list = function
    | [] -> failwith "Error"
    | [a] -> a, list
    | h::t -> extract_last_rec (list@[h]) t
  in extract_last_rec [] l
