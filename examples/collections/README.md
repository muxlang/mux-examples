# collections

Lists, maps, and sets, each doing one useful job.

Covers:

- lists: ordering, duplicates, indexing (including negative indices), and `get`
  for when the index might not be there
- maps: `put`, `contains`, and key access
- sets: uniqueness, `add`, `contains`
- nesting, and combining two collections of the same kind with `+`

The three share a vocabulary - `size`, `is_empty`, `contains` - so learning one
teaches you most of the others.

Note that the empty **map** literal is `{:}`. Plain `{}` is the empty **set**.

```bash
mux run main.mux
```
