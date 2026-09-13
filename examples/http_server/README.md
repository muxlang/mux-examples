# http_server

An HTTP server and a client talking to each other over loopback.

Uses `std.net` (TcpListener, typed `HttpRequest`/`HttpResponse`, and `Headers`)
and `std.sync` (threads). The server binds an ephemeral port on `127.0.0.1`,
the client runs on a second thread, and both shut down cleanly. Nothing leaves
the machine and the port number never reaches the output, so the result is
identical on every run.

## The two things worth reading for

**Shape.** Every fallible call returns a `result`. The client helper uses `use`
for its typed HTTP result. The server crosses several error domains (network,
HTTP, and synchronization), so it inspects those results and converts their
messages at one explicit boundary; a single `result` cannot carry unrelated
error types. The thread body remains a single assignment.

**Determinism.** The client returns its status instead of printing it, and the
main thread prints after `join`. Two threads printing race, and an example whose
line order varies cannot be checked against a recorded output. This is the
general rule for concurrent code you intend to test.

## Notes

- Requests are built with `HttpRequest.new()`, then configured by assigning
  `method` and `url` directly. `send()` is the one general client operation.
- Server requests and responses use the same typed handles. `Headers` is
  configured independently, and the response body is explicit `bytes`.
- The client thread body is a single assignment, with error inspection kept in
  `fetch_status_or_error`, so the thread says what it does rather than how.

```bash
mux run main.mux
```
