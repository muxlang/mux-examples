# inventory_report

Aggregate a list of records into a grouped report.

A shape most programs need eventually: model the data with a class, group it
with maps keyed by category, then print totals.

The detail worth copying is `order`. Grouping needs a map for the lookup, but a
map is not the right thing to iterate for display. The program keeps a separate
list recording the order categories were first seen, and reports in that order.
Deciding your own output order is what keeps a report stable.

> The obvious alternative is to sort the category names, which is not currently
> possible: `algorithm.sort` on a `list<string>` returns the list unchanged
> (muxlang/mux-compiler#390). First-seen order is a good answer regardless, but
> that bug is why it is the only answer here.

```bash
mux run main.mux
```
