type 'a t =
    {
      elem : 'a;
      elem_loc : Location.t;
    }
let mk_elem e l =
    {
      elem = e;
      elem_loc = l;
    }

let elem_of e = e.elem
let loc_of e = e.elem_loc
