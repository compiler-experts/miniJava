let print name print_key print_val hashtbl =
  if (Hashtbl.length hashtbl > 0) then
    begin
      if (name <> "") then print_string (name^": ");
      let first = ref true in
      Hashtbl.iter 
	(fun key value -> 
	  if !first then
	    first := false
	  else
	    print_string ", ";
	  print_key key;
	  print_string ":";
	  print_val value)
	hashtbl
    end
