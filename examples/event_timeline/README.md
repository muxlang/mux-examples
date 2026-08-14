# event_timeline

Sort events by time and format them for reading.

Uses `std.datetime` for formatting and calendar fields, and `algorithm.sort`
from `std.dsa` to order the timestamps.

The point worth copying is that the timestamps are **fixed constants**, not
`datetime.now()`. A program whose output depends on the clock cannot be checked
against a known result, which is exactly why this repo's CI can verify this
example and could not verify one that read the current time.

Also shows that calendar accessors return `result` rather than a bare int, since
not every integer is a valid timestamp on every platform.

```bash
mux run main.mux
```
