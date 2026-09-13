# optional_and_result

Handling absence and failure without exceptions.

Mux has no exceptions. Two types cover what exceptions usually do:

- `optional<T>` - the value might not be there. Missing is ordinary, not an
  error. Opened with `some(v)` / `none`.
- `result<T, E>` - the operation might fail, and the failure has something to
  say. Opened with `ok(v)` / `err(e)`.

Use `use` when a missing value or error should propagate; use `is_some()` /
`is_err()` inspection or `match` when both branches need different work. The
compiler still makes the unhappy path explicit, so you cannot accidentally use
a value that was never there.

The `average` function shows how results compose: it returns early with `err`,
and the error from a nested call travels back up untouched.

```bash
mux run main.mux
```
