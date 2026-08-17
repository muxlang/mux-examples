# route_finder

Find the shortest route between two stations with breadth-first search.

Uses `Graph` and `Queue` from `std.dsa`, but writes the search out by hand
rather than calling the built-in `graph.bfs`. The reason is the useful answer:
`bfs` tells you which vertices you visited, and what you usually want is *how to
get there*. The difference is the `came_from` map, which records the step that
first reached each station so the path can be walked backwards at the end.

BFS finds the fewest-hops route because it explores everything one hop away
before anything two hops away.

The graph is directed, so each two-way line is added as a pair of edges. The
last case shows an isolated vertex, reachable from nowhere.

```bash
mux run main.mux
```
