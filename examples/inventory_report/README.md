# inventory_report

Aggregate a list of records into a grouped report.

A shape most programs need eventually: model the data with a class, group it
with maps keyed by category, then print totals.

The detail worth copying is `order`. Grouping needs a map for the lookup, but a
map is not the right thing to iterate for display. The program keeps a separate
list recording the order categories were first seen, and reports in that order.
Deciding your own output order is what keeps a report stable.

> Sorting the category names is the obvious alternative, and `algorithm.sort`
> on a `list<string>` does work. First-seen order is chosen deliberately: it
> reports categories in the order the source data introduces them, which is
> usually what someone reading that data expects, and it needs no second pass.

```bash
mux run main.mux
```
