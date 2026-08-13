# enums_and_match

Enums that carry data, and getting that data back out.

A Mux enum is a tagged union: each variant can hold its own typed fields.
`match` destructures them, and the compiler checks exhaustiveness - add a
variant and every match that forgot it stops building, which is the point.

Also shows that enums compare by value, so two separately constructed variants
with equal payloads are equal. That is what lets them work as set members and
map keys.

```bash
mux run main.mux
```
