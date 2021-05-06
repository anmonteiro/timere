type t = {
  hour : int;
  minute : int;
  second : int;
  ns : int;
}

type error =
  [ `Invalid_hour of int
  | `Invalid_minute of int
  | `Invalid_second of int
  | `Invalid_s_frac of float
  | `Invalid_ns of int
  ]

exception Error_exn of error

let make ?(ns = 0) ?(s_frac = 0.0) ~hour ~minute ~second () : (t, error) result =
  if hour < 0 || 24 < hour then Error (`Invalid_hour hour)
  else if minute < 0 || 59 < minute then Error (`Invalid_minute minute)
  else if second < 0 || 60 < second then Error (`Invalid_second second)
  else if s_frac < 0. then Error (`Invalid_s_frac s_frac)
  else if ns < 0 then Error (`Invalid_ns ns)
  else
    let ns = ns + int_of_float (s_frac *. Span.ns_count_in_s_float) in
    if ns >= Span.ns_count_in_s then Error (`Invalid_ns ns) else
      match
        (
          if hour = 24 then
            if minute = 0 && second = 0 && ns = 0 then
              Ok (hour, minute, second, ns)
            else
              Error (`Invalid_hour hour)
          else
            Ok (hour, minute, second, ns)
        )
      with
      | Error e -> Error e
      | Ok (hour, minute, second, ns) ->
      let is_leap_second = second = 60 in
      let second = if is_leap_second then 59 else second in
      let ns =
        if is_leap_second then
          ns + Span.ns_count_in_s
        else
          ns
      in
      Ok { hour; minute; second; ns }

let make_exn ?ns ?s_frac ~hour ~minute ~second () : t =
  match make ~hour ~minute ~second ?ns ?s_frac () with
  | Error e -> raise (Error_exn e)
  | Ok x -> x

let to_span (x : t) : Span.t =
  Span.For_human'.make_exn ~hours:x.hour ~minutes:x.minute ~seconds:x.second
    ~ns:(x.ns mod Span.ns_count_in_s) ()

let of_span (x : Span.t) : t option =
  if Span.(zero <= x && x < Constants.one_day) then
    let v = Span.For_human'.view x in
    Some { hour = v.hours; minute = v.minutes; second = v.seconds; ns = v.ns }
  else
    None

let is_leap_second (x : t) = x.ns >= Span.ns_count_in_s

let equal (x : t) (y : t) =
  x.hour = y.hour
  && x.minute = y.minute
  && x.second = y.second
  && x.ns = y.ns
