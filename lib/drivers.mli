(** Interfaces with core libraries to provide a command-line interface. *)
module Cli : sig
  val main : unit -> unit
  (** Runs Advent of Code problem runner, via a command-line interface. *)
end
