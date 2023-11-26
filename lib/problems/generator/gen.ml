let pp_module_name (f : Format.formatter) (module_name : string) : unit =
  Fmt.pf f "(module %s: Problem.T)" module_name

let pp_file (f : Format.formatter) (module_names : string list) : unit =
  Fmt.(
    pf f {ocaml|let all: (module Problem.T) list = [%a]|ocaml}
      (list ~sep:semi pp_module_name)
      module_names)

let () =
  let output_filename = Array.get Sys.argv 1 in
  let filenames =
    Sys.argv |> Array.to_list |> List.tl |> List.tl
    |> List.map
         (String.mapi (fun i c -> if i = 0 then Char.uppercase_ascii c else c))
    |> List.map (fun s -> String.sub s 0 (String.length s - 3))
  in
  let contents = Fmt.str "%a" pp_file filenames in
  let c = open_out output_filename in
  output_string c contents;
  close_out c
