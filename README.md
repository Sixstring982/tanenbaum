**_Tanenbaum_**

![Tanenbaum logo](https://github.com/Sixstring982/tanenbaum/blob/main/public/logo.webp?raw=true "Tanenbaum logo")

# Summary

_Tanenbaum_ is an OCaml starter project for Advent of Code.

## Feature overview

- Automatic downloading + caching of puzzle inputs
- CLI for running puzzles + submitting answers to `adventofcode.com`
- Automatic puzzle detection + registration
- ReasonML support out of the box

# Quick-start

## Project setup

First, clone or fork this repo.

### Create your opam switch

```bash
$ opam switch create . --deps-only --y
```

### Install developer tool dependencies

```bash
$ opam install ocaml-lsp-server ocamlformat utop
```

### Validate you can build with dune

```bash
$ dune build
```

> [!INFO]
> If any of these steps fail or cause an error please open an issue

## Configure authentication

_Tanenbaum_ needs a session token from `adventofcode.com` in order to download
your puzzle inputs and submit your answers.

Start by logging in to `adventofcode.com`, then browsing to one of the puzzle
dashboards (e.g. https://adventofcode.com/2015).

Open your developer tools and reload the page. This should issue a GET request,
e.g. `GET https://adventofcode.com/2015`. Look for the `Cookie: ` request
header, which should contain a value that looks like (where `x` is a hex value):

```
session=5xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx5
```

This value is your session token. You'll need to store it as an environment
variable called `AUTH_TOKEN`. One convenient way of doing this is to use a tool
like [direnv](https://direnv.net/), e.g.:

`.envrc`:

```shell
export AUTH_TOKEN="5xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx5"
```

## Working on problems

Each problem needs to conform to the `Problem.T` interface, which provides basic
information about which year/day the problem is for, and functions to call which
compute the puzzle output from puzzle input.

### Adding problem files

_Tanenbaum_ will automatically register `.ml` or `.re` files in `lib/problems` which start
with `problem` -- e.g. `lib/problems/problem_2022_01.ml` or `lib/problems/problem_2022_01.re.
Once you've added a file of this form, you can run it from the CLI.

For example, if we'd like to start working on day 1 of year 2022, _Tanenbaum_
will automatically we can add this file:

#### OCaml

`lib/problems/problem_2022_01.ml`;

```ocaml
let year = 2022
let day = 1

module Part_1 = struct
  let run (input : string) : (string, string) result = Ok input
end

module Part_2 = struct
  let run (input : string) : (string, string) result = Ok input
end
```

#### ReasonML

`lib/problems/problem_2022_01.re`;

```reason
let year = 2022;
let day = 1;

module Part_1 = {
  let run = (input: string): result(string, string) => Ok(input);
};

module Part_2 = {
  let run = (input: string): result(string, string) => Ok(input);
};
```

> [!TIP]
> It's also helpful to add a `.mli` or `.rei` file, which gives the compiler more
> information about which parts of your code are unused and can therefore be
> cleaned up:

### OCaml

`lib/problems/problem_2022_01.mli`:

```ocaml_interface
include Problem.T
```

### ReasonML

`lib/problems/problem_2022_01.rei`:

```reason_interface
include Problem.T;
```

### Running problems

Once you've added your problem, you can run it with `dune` (optionally providing
the `--watch` flag will re-run your problem when you change your code):

```shell
dune exec --watch bin/main.exe -- \
  --year=2022 \
  --day=1 \
  --part=1
```

### Submitting answers

Once you're convinced that your problem produces the correct output, you can
also submit your answer using the CLI via the `--submit` flag.

> [!WARNING]
> You'll want to disable the `--watch` flag if you have it enabled -- otherwise
> you'll end up making a lot of requests to `adventofcode.com`...

```shell
dune exec bin/main.exe -- \
  --year=2022 \
  --day=1 \
  --part=1 \
  --submit
```

# Tips and tricks

## Testing against other inputs

Advent of Code typically provides smaller inputs, in order to check that your
code works. I tend to allow _Tanenbaum_ to download the puzzle input first, then
I can replace the puzzle input with whatever input I'd like to test.

I can then revert back to the official puzzle input by deleting the file
(_Tanenbaum_ will download a fresh copy when I run it again).
