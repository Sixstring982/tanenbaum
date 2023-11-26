(** [f << g] composes [f] with [g] right-to-left -- i.e. [f (g x)] *)
let (<<) f g x = f (g x)

(** [f << g] composes [f] with [g] left-to-right -- i.e. [g (f x)] *)
let (>>) f g x = g (f x)
