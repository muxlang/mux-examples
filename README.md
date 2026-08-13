# mux-examples

Runnable example programs for the [Mux](https://github.com/muxlang/mux-compiler)
language.

Every example here is a complete program that compiles, runs, and produces a
known output that CI checks. Nothing in this repo is a fragment.

## Running one

```bash
cd examples/hello
mux run main.mux
```

## The examples

### Language essentials

Start here if you are new to Mux.

| Example | What it shows |
| --- | --- |
| [hello](examples/hello) | the smallest complete program |
| [collections](examples/collections) | lists, maps, and sets |
| [classes_and_interfaces](examples/classes_and_interfaces) | classes, and why an interface is a bound rather than a value type |
| [enums_and_match](examples/enums_and_match) | enums that carry data, and exhaustive matching |
| [optional_and_result](examples/optional_and_result) | handling absence and failure without exceptions |
| [generics_and_closures](examples/generics_and_closures) | generic types, and functions as values |

### Programs that do a job

Each of these uses the standard library to complete a real task end to end.

| Example | What it shows | Uses |
| --- | --- | --- |
| [csv_to_json](examples/csv_to_json) | read a CSV file, emit each row as JSON | `io`, `data.csv`, `data.json` |
| [inventory_report](examples/inventory_report) | group records and total them | collections, classes |
| [event_timeline](examples/event_timeline) | order and format timestamped events | `datetime`, `dsa` |
| [route_finder](examples/route_finder) | shortest path with breadth-first search | `dsa` (graph, queue) |
| [dice_simulation](examples/dice_simulation) | seeded sampling with assertions | `random`, `assert` |
| [http_server](examples/http_server) | a server and client over loopback, on two threads | `net`, `sync`, `data.json` |

## How these are verified

`scripts/run-examples.sh` compiles and runs every example and diffs its output
against the `expected_output.txt` recorded next to it.

```bash
MUX_BIN=/path/to/mux ./scripts/run-examples.sh          # check all
MUX_BIN=/path/to/mux ./scripts/run-examples.sh hello    # check one
MUX_BIN=/path/to/mux ./scripts/run-examples.sh --update # re-record expected output
```

That script is the shared contract. Three things call it:

- this repo's CI, against mux-compiler `main`, on every pull request
- mux-compiler's release job, against the compiler being released
- mux-runtime's release job, against the runtime being released

The release jobs are what guarantee the examples work with a compiler you can
actually install.

## Adding an example

1. Create `examples/<name>/main.mux`.
2. Write a short `README.md` next to it saying what it teaches.
3. Record the output: `MUX_BIN=... ./scripts/run-examples.sh --update <name>`.
4. Read the generated `expected_output.txt` before committing it. It is the
   assertion, so it has to be output you actually want.

An example must be **deterministic and offline**. No clock, no network, no
unseeded randomness, no dependence on the filesystem beyond files it writes
itself. Anything else cannot be checked against a recorded result.

## What this repo is not

This is not the compiler's test suite. That lives in `mux-compiler/test_scripts/`
and is a different artifact with a different job: it pins compiler behavior,
about half of it is programs that must *fail* to compile, and it tracks the
compiler's `main` rather than a release.

The reasoning behind keeping them separate is recorded in
[muxlang/mux-context](https://github.com/muxlang/mux-context).
