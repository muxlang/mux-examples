# generics_and_closures

Generic types, and functions treated as values.

Generics are monomorphized: the compiler stamps out a copy per concrete type, so
`Stack<int>` costs no more than a hand-written int stack. The same class used at
`Stack<string>` is a separate, equally specialized type.

Closures are ordinary values. The example shows all three things you can do with
one:

- return it, as `make_counter` does - the captured variable stays alive between
  calls, and each counter gets its own
- pass it, as `apply_all` takes one to parameterize behavior rather than data
- capture surrounding state, as the `factor` closure does

```bash
mux run main.mux
```
