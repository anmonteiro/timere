module Duration = Duration
include Time

type 'a range = 'a Range.range

type interval = Interval.t

module Infix = struct
  let ( & ) = Time.inter

  let ( ||| ) = Time.union

  let ( -- ) = Time.interval_inc

  let ( --^ ) = Time.interval_exc

  let ( --* ) = Time.intervals_inc

  let ( --*^ ) = Time.intervals_exc
end

let resolve = Resolver.resolve

module Parse = struct
  let timere = Parser.parse

  let date_time = Parser.parse_date_time

  let duration = Parser.parse_duration
end
