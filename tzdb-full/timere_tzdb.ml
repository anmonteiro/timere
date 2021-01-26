module M = Map.Make (String)

type entry = {
  is_dst : bool;
  offset : int;
}

type table =
  (int64, Bigarray.int64_elt, Bigarray.c_layout) Bigarray.Array1.t * entry array

type db = table M.t

let db : db = Marshal.from_string Tzdb_marshalled.s 0

let lookup name = M.find_opt name db

let available_time_zones = List.map fst (M.bindings db)
