type 'a node = Node of ('a * 'a node) list

type 'a t = Hierarchy of 'a * 'a node * 'a t list


let create rootname = Hierarchy(rootname, Node [], [])

let rec add_node Node(children_list) elt_child elt_father =
    match add_list children_list elt_child elt_father with
    | true, ch_list -> true, Hierarchy(rootname, Node(ch_list), unclassified)
    | false, ch_list -> true, Hierarchy(rootname, Node(ch_list), add_unclassified unclassified elt_child elt_father)
and add_list children_list elt_child elt_father =
  match children_list with
  | [] -> false, []
  | (c,subchildren)::other_children when c == elt_father -> 
     true, ((c,Node((elt_child, Node [])::subchildren))::other_children)
  | (c,subchildren)::other_children ->
     match add (Hierarchy(c,,)) elt_child elt_father with
     | true, result_children -> true, (c,subchildren)::result_children
     | false, _ ->      match add_list other_children elt_child elt_father with

let add (Hierarchy(rootname, node, unclassified)) elt_child elt_father =
  if rootname == elt_father then
    true, Hierarchy(rootname, Node((elt_child, Node [])::children_list), unclassified)
  else
    match add_node node elt_child elt_father with
    | true, ch_list -> true, Hierarchy(rootname, Node(ch_list), unclassified)
    | false, ch_list -> true, Hierarchy(rootname, Node(ch_list), add_unclassified unclassified elt_child elt_father)
