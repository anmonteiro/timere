open Test_utils

module Qc = struct
  let to_of_sexp =
    QCheck.Test.make ~count:10_000 ~name:"to_of_sexp" time (fun t ->
        let t' = t |> To_sexp.to_sexp |> Of_sexp.of_sexp |> Result.get_ok in
        Time.equal t t')

  let union_order_does_not_matter =
    QCheck.Test.make ~count:10 ~name:"union_order_does_not_matter" QCheck.(pair (int_bound 10) time_list)
      (fun (rand, l1) ->
         let l2 = permute rand l1 in
         let t1 = Time.union l1 in
         let t2 = Time.union l2 in
         let r1 = Result.get_ok @@ Resolver.resolve t1 in
         let r2 = Result.get_ok @@ Resolver.resolve t2 in
         OSeq.equal ~eq:( = ) r1 r2
      )

  let inter_order_does_not_matter =
    QCheck.Test.make ~count:10 ~name:"inter_order_does_not_matter" QCheck.(pair (int_bound 10) time_list)
      (fun (rand, l1) ->
         let l2 = permute rand l1 in
         let t1 = Time.inter l1 in
         let t2 = Time.inter l2 in
         let r1 = Result.get_ok @@ Resolver.resolve t1 in
         let r2 = Result.get_ok @@ Resolver.resolve t2 in
         OSeq.equal ~eq:( = ) r1 r2
      )

  let suite =
    [
      to_of_sexp;
      union_order_does_not_matter;
      inter_order_does_not_matter;
    ]
end
