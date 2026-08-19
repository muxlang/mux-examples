# mux-examples: AI Agent Guidelines

Runnable example programs for the Mux language. Part of the multi-repo
[muxlang](https://github.com/muxlang) ecosystem.

> Cross-repo architecture, design rationale, the feature map, and the release
> process live in [muxlang/mux-context](https://github.com/muxlang/mux-context).

## What this is

Complete Mux programs, each in its own directory under `examples/`, with a
recorded `expected_output.txt` that CI diffs against. This repo contains no
fragments and no programs that fail on purpose.

It is **not** the compiler's test corpus. That is `mux-compiler/test_scripts/`,
which pins compiler behavior, is roughly half deliberately-invalid programs, and
tracks compiler `main`. Keeping the two separate is a recorded decision - do not
merge them or vendor one into the other.

## Critical Rules

- **No special characters** - ASCII only in code, comments, and commit messages.
- **Every example must be deterministic and offline.** No `datetime.now()`, no
  network, no unseeded randomness, no dependence on files it did not write
  itself. A recorded output is the assertion, so anything that varies between
  runs cannot be an example here.
- **An example teaches.** If a program only exercises a feature without
  explaining anything, it belongs in `mux-compiler/test_scripts/` instead.
- **Read `expected_output.txt` before committing it.** It is generated, but it
  is also the assertion. Generated-and-unreviewed is how a wrong output becomes
  the baseline.
- **Do not duplicate the website.** If the content is a doc snippet with a
  `main` wrapped around it, it belongs in `mux-website/docs/`.

## Layout

```
examples/<name>/
  main.mux              the program
  README.md             what it teaches
  expected_output.txt   generated, reviewed, and diffed by CI
```

`main.mux` is the filename in every example so the runner needs no per-example
configuration.

## Development

```bash
MUX_BIN=/path/to/mux ./scripts/run-examples.sh            # check all
MUX_BIN=/path/to/mux ./scripts/run-examples.sh hello      # check one
MUX_BIN=/path/to/mux ./scripts/run-examples.sh --update   # re-record output
```

`MUX_RUNTIME_LIB` is forwarded untouched if set. Building the compiler from
source requires building the runtime in the same command
(`cargo build -p mux-runtime -p mux-lang`), or nothing links.

## Hard-won facts

- **`{:}` is the empty map; `{}` is the empty set.** An empty map literal also
  cannot be type-inferred - annotate it.
- **An expression may span lines inside an open bracket** (since 0.9.0). A long
  call or literal can wrap, and a trailing comma before the closing bracket is
  allowed. Outside brackets a newline still ends the statement.
- **An interface cannot be a value type.** No `list<SomeInterface>`. Take it as
  a generic bound instead.
- **Importing a type brings its interfaces with it** (since 0.9.0).
  `import std.dsa.graph.Graph` no longer needs `std.dsa.collection.Collection`
  alongside it.
- **A namespace import binds the namespace, not its contents.** After
  `import std.net`, the type is `net.TcpListener`; the bare name is not in
  scope. Import it directly or with `.*` to use the short form.

Known compiler and runtime gaps that the current examples work around, and what
to undo when they are fixed, are tracked in the workarounds note referenced from
muxlang/mux-context#26.

## CI

`.github/workflows/examples.yml` builds mux-compiler `main` and runs
`scripts/run-examples.sh`. It is deliberately not path-filtered: it is a
required check, and a required check skipped by a paths filter never reports, so
the pull request would wait on it forever.

**Add to this document as you learn vital information.**
