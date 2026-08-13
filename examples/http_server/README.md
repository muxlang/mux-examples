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

## Known rough edges this example works around

- `"GET"` and `"/echo"` print **with quotes**. `Json` has one method,
  `stringify`, so a string field arrives JSON-encoded and there is no way to
  strip the quotes (muxlang/mux-compiler#392, #389). It is also why the router
  compares against `"\"/echo\""`.
- The status prints as `201.0`, not `201`. Every JSON number is parsed as a
  float (muxlang/mux-runtime#52).
- The client thread body is a single assignment because writing a captured
  variable from inside a `match` arm in a closure is an internal compiler error
  (muxlang/mux-compiler#394). Extracting the work into `fetch_status` is the
  better structure anyway.

```bash
mux run main.mux
```
