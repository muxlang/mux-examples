# http_server

An HTTP server and a client talking to each other over loopback.

Uses `std.net` (TcpListener, the `http` helpers), `std.sync` (threads), and
`std.data.json`. The server binds an ephemeral port on `127.0.0.1`, the client
runs on a second thread, and both shut down cleanly. Nothing leaves the machine
and the port number never reaches the output, so the result is identical on
every run.

## The two things worth reading for

**Shape.** Every fallible call returns a `result`, and Mux has no exceptions and
no propagation operator, so nesting a `match` per call buries the logic. Where a
value has a natural default the example declares it first, matches immediately,
binds on `ok` and returns on `err` - four lines per call, but the function stays
flat. Where the value is a class (`TcpStream` from `accept`) that is not
possible, because a variable cannot be declared without initializing it
(muxlang/mux-compiler#393), so the outer `match` stays nested.

**Determinism.** The client returns its status instead of printing it, and the
main thread prints after `join`. Two threads printing race, and an example whose
line order varies cannot be checked against a recorded output. This is the
general rule for concurrent code you intend to test.

## Notes

- **Read fields with the typed accessors, not `stringify`.** `stringify` returns
  the JSON *encoding* of a value, so a string field comes back as `"/echo"` with
  the quotes; `as_string` returns `/echo`. Each accessor returns an `optional`,
  because a field holding a different kind than you expected is ordinary when
  reading a document you did not write - which is why `status` goes through
  `as_int` and not `as_string`.
- The client thread body is a single assignment, with the matching extracted
  into `fetch_status`, so the thread says what it does rather than how.

```bash
mux run main.mux
```
