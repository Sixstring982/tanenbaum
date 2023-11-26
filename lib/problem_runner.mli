(** Credentials are used to authenticate with [adventofcode.com], to automate some slightly 
    annoying things that you need to do when working on puzzle solutions. *)
module Credentials : sig
  type t
  (** A complete set of credentials used to authenticate with [adventofcode.com]. *)

  val of_auth_token : string -> t
  (** [of_auth_token session_token] constructs a [t] from the session token issued by 
      [adventofcode.com]. *)
end

(** Specifies the way that we'd like our problem runner to run. *)
module Run_mode : sig
  (** Specifies the way that we'd like our problem runner to run. *)
  type t =
    | Test_from_puzzle_input of { credentials : Credentials.t option }
        (** Indicates that we'd like to test the puzzle solution that we're working on, without 
        submitting the answer to [adventofcode.com] *)
    | Submit of { credentials : Credentials.t }
        (** Indicates that we'd like to run a puzzle solution, and if successful, submit the answer to
        [adventofcode.com] *)
end

(** Fully configures an invocation of [run]. *)
module Options : sig
  type t = {
    year : int;
        (** The "year" of the puzzle that we'd like to run -- e.g. [2015], or [2022]. *)
    day : int;
        (** The "day" of the puzzle that we'd like to run -- e.g. [1], or [18]. *)
    part : int;
        (** The "part" of the puzzle that we'd like to run -- i.e. [1], or [2]. *)
    run_mode : Run_mode.t;
        (** The "run_mode" of the puzzle that we'd like to run. See [Run_mode] for more details. *)
  }
  (** Fully configures an invocation of [run]. *)
end

val run : Options.t -> (string, string) result
(** [run options] runs a puzzle solution, configured by [options]. 

    This may return [Error] for a number of reasons -- the returned [string] should indicate what
    went wrong. *)
