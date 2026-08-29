# mux-examples

`mux-examples` contains complete, deterministic Mux programs that teach one
or more language features. Each example has a README and a reviewed expected
output file.

Cross-repository architecture and release facts live in
[`mux-context`](https://github.com/muxlang/mux-context). Read its canonical
[`SKILL.md`](https://github.com/muxlang/mux-context/blob/main/SKILL.md) before
changing an example that exercises compiler or runtime behavior.

## Invariants

- Examples are offline, deterministic, and complete; they do not access
  undeclared files, services, clocks, or unseeded randomness.
- Keep `expected_output.txt` in sync by running the example runner and review
  the output rather than hand-editing it.
- Compiler fixtures belong in `mux-compiler/test_scripts/`, not here. Examples
  must teach a user-facing concept.

## Quality gate

Run `MUX_BIN=/path/to/mux ./scripts/run-examples.sh` (and the CI checks) before
committing. Do not leave compiled binaries in the repository.

## Documentation

See [`README.md`](README.md), each example's README, and the linked context
workaround notes.
