# csv_to_json

Read a CSV file and emit each row as a JSON object.

The classic glue task: text in one shape, text out in another, with every step
able to fail. Uses `std.fs`, `std.data.csv`, and `std.data.json` together.

Worth noticing how the failures compose. Reading, parsing, and serializing each
return a `result`, and `use` keeps the happy path flat while propagating errors
to the enclosing function. Local `is_err`/`error`/`value` inspection handles
the one place where the program needs to choose its own message.

The program writes its own input file so it is self-contained, and removes it on
the way out.

```bash
mux run main.mux
```
