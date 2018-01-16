include Map.Make(Address)

let print name print_val map =
  if (not(is_empty map)) then
    begin
      if (name <> "") then print_string (name^": ");
      let first = ref true in
      iter 
	(fun key value -> 
	  if !first then
	    first := false
	  else
	    print_string ", ";
	  print_int key;
	  print_string ":";
	  print_val value)
	map
    end
