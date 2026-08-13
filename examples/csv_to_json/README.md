# csv_to_json

Read a CSV file and emit each row as a JSON object.

The classic glue task: text in one shape, text out in another, with every step
able to fail. Uses `std.io`, `std.data.csv`, and `std.data.json` together.

Worth noticing how the failures stack. Reading, parsing, and serializing each
return a `result`, and each is opened with `match` before the value inside is
touched. There is no way to skip a check and no exception to forget to catch.

The program writes its own input file so it is self-contained, and removes it on
the way out.

```bash
mux run main.mux
```
