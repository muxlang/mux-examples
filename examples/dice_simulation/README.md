# dice_simulation

Roll dice many times and check the resulting distribution.

Uses `std.random` and `std.assert`.

`random.seed` is what makes this testable. The generator is a plain LCG, so a
fixed seed produces the same sequence on every run and every machine. Seeded, the
output is a known quantity CI can compare against; unseeded, it seeds itself from
the clock, which is right for a real program and useless for a test. The end of
the example demonstrates the replay directly.

`assert` then states properties that must hold regardless of the rolls: every
roll landed on exactly one face, and no face strayed far from its expected
share. A failing assertion stops the program.

> The rolls use `random.next_int() % SIDES + 1` rather than the more obvious
> `random.next_range(1, SIDES + 1)`, because `next_range` currently returns only
> the lower half of its range and would never roll above a 3
> (muxlang/mux-runtime#50).

```bash
mux run main.mux
```
