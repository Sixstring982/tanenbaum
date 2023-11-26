open Import

module Cli = struct
  open Cmdliner

  module Terms = struct
    let year =
      let doc = "Run problems from year $(docv)." in
      Arg.(value & opt (some int) None & info [ "year" ] ~docv:"YEAR" ~doc)

    let day =
      let doc = {|Run problem number "day" $(docv).|} in
      Arg.(value & opt (some int) None & info [ "day" ] ~docv:"DAY" ~doc)

    let part =
      let doc = "Run problem part $(docv)." in
      Arg.(value & opt (some int) None & info [ "part" ] ~docv:"PART" ~doc)

    let auth_token =
      let doc =
        "Some operations require authenticating with adventofcode.com . This \
         is the token used for authentication."
      in
      let env = Cmd.Env.(info "AUTH_TOKEN" ~doc) in
      Arg.(
        value
        & opt (some string) None
        & info [ "auth_token" ] ~docv:"AUTH_TOKEN" ~doc ~env)

    let submit =
      let doc =
        "If set, attempts to submit the problem output to adventofcode.com."
      in
      Arg.(value & flag & info [ "submit" ] ~docv:"SUBMIT" ~doc)
  end

  let run (year : int option) (day : int option) (part : int option)
      (auth_token : string option) (submit : bool) : unit Cmdliner.Term.ret =
    match (year, day, part) with
    | None, _, _ -> `Error (false, {|"year" argument required.|})
    | _, None, _ -> `Error (false, {|"day" argument required.|})
    | _, _, None -> `Error (false, {|"part" argument required.|})
    | Some year, Some day, Some part -> (
        let output =
          let@ (run_mode : Problem_runner.Run_mode.t) =
            match (auth_token, submit) with
            | None, true ->
                Error {|Must provide AUTH_TOKEN when using --submit|}
            | token, false ->
                Ok
                  (Problem_runner.Run_mode.Test_from_puzzle_input
                     {
                       credentials =
                         Option.map Problem_runner.Credentials.of_auth_token
                           token;
                     })
            | Some token, true ->
                Ok
                  (Problem_runner.Run_mode.Submit
                     {
                       credentials =
                         Problem_runner.Credentials.of_auth_token token;
                     })
          in
          Problem_runner.(run { year; day; part; run_mode })
        in

        match output with
        | Ok output ->
            print_endline output;
            `Ok ()
        | Error error_msg -> `Error (false, error_msg))

  let main () =
    let info = Cmd.info "tanenbaum" in
    let cmd =
      Cmd.v info
        Term.(
          ret
            (const run $ Terms.year $ Terms.day $ Terms.part $ Terms.auth_token
           $ Terms.submit))
    in
    exit @@ Cmdliner.Cmd.eval cmd
end
