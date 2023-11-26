open Import

module Credentials = struct
  type t = string

  let of_auth_token (x : string) : t = x

  let to_headers (t : t) : (string * string) list =
    [ ("Cookie", "session=" ^ t) ]
end

module Run_mode = struct
  type t =
    | Test_from_puzzle_input of { credentials : Credentials.t option }
    | Submit of { credentials : Credentials.t }

  let read_file (filename : string) : string =
    let ch = open_in_bin filename in
    let s = really_input_string ch (in_channel_length ch) in
    close_in ch;
    s

  let write_file (filename : string) (contents : string) : unit =
    let ch = open_out_bin filename in
    let () = output_string ch contents in
    close_out ch

  let get_puzzle_input (year : int) (day : int)
      (credentials : Credentials.t option) : (string, string) result =
    (* Create cache directory structure *)
    let () =
      if not (Sys.file_exists "inputs") then Sys.mkdir "inputs" 0o777 else ()
    in
    let year_dir = Filename.concat "inputs" @@ string_of_int year in
    let () =
      if not (Sys.file_exists year_dir) then Sys.mkdir year_dir 0o777 else ()
    in

    (* Check if cached input exists *)
    let filename =
      Filename.concat year_dir @@ Format.sprintf "%02d.txt" day
    in
    if Sys.file_exists filename then Ok (read_file filename)
      (* If not, fetch it from adventofcode.com *)
    else
      match credentials with
      | None ->
          Error "Cannot fetch input from adventofcode.com: missing credentials."
      | Some credentials ->
          Result.map_error Piaf.Error.to_string
          @@ Lwt_main.run
          @@
          let uri =
            Uri.of_string
            @@ String.concat "/"
                 [
                   "https://adventofcode.com";
                   string_of_int year;
                   "day";
                   string_of_int day;
                   "input";
                 ]
          in
          let headers = Credentials.to_headers credentials in
          let* response = Piaf.Client.Oneshot.get ~headers uri in
          let* body = Piaf.Body.to_string response.body in
          write_file filename body;
          Lwt_result.return body

  let get_input (year : int) (day : int) : t -> (string, string) result =
    function
    | Test_from_puzzle_input { credentials } ->
        get_puzzle_input year day credentials
    | Submit { credentials } -> get_puzzle_input year day (Some credentials)

  let cleanup (year : int) (day : int) (part : int) (output : string)
      (run_mode : t) : (string option, string) result =
    match run_mode with
    | Test_from_puzzle_input _ -> Ok None
    | Submit { credentials } ->
        Result.map_error Piaf.Error.to_string
        @@ Lwt_main.run
        @@
        let uri =
          Uri.of_string
          @@ String.concat "/"
               [
                 "https://adventofcode.com";
                 string_of_int year;
                 "day";
                 string_of_int day;
                 "answer";
               ]
        in
        let headers = Credentials.to_headers credentials in
        let headers =
          headers @ [ ("Content-Type", "application/x-www-form-urlencoded") ]
        in
        let body =
          Piaf.Body.of_string @@ Fmt.(str "level=%d&answer=%s" part output)
        in
        let* response = Piaf.Client.Oneshot.post ~headers ~body uri in
        let* body = Piaf.Body.to_string response.body in
        Lwt_result.return (Some body)
end

module Options = struct
  type t = { year : int; day : int; part : int; run_mode : Run_mode.t }
end

let run_problem (module Problem : Problem.T) (run_mode : Run_mode.t)
    (year : int) (day : int) (part : int) : (string, string) result =
  let@ input = Run_mode.get_input year day run_mode in
  let@ result =
    match part with
    | 1 -> Problem.Part_1.run input
    | 2 -> Problem.Part_2.run input
    | p -> Error (Format.sprintf {|Invalid part "%d". Expected "1" or "2".|} p)
  in
  let@ cleanup_result = Run_mode.cleanup year day part result run_mode in
  let () =
    match cleanup_result with None -> () | Some result -> print_endline result
  in
  Ok result

let find_problem (year : int) (day : int) :
    ((module Problem.T), string) result =
  match
    List.find_opt
      (fun (module Problem : Problem.T) ->
        Problem.year = year && Problem.day = day)
      Problems.All.all
  with
  | Some p -> Ok p
  | None ->
      Error
        (Format.sprintf "Problem (year = %d, day = %d) not implemented."
           year day)

let run (options : Options.t) : (string, string) result =
  let@ problem = find_problem options.year options.day in
  run_problem problem options.run_mode options.year options.day options.part
