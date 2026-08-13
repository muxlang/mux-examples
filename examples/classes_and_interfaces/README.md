# classes_and_interfaces

Classes, and the thing about Mux interfaces that surprises people.

An interface is a **bound**, not a value type. You cannot declare a
`list<Shape>` and fill it with mixed classes:

```
error: 'Shape' is an interface and cannot be used as a value type
= help: Take it as a bound instead, e.g. 'func f<T is Shape>(T value)'.
```

Mux resolves interface calls statically - there is no vtable and no runtime
lookup - so instead of a heterogeneous collection you write a generic function
bounded by the interface, and the compiler generates one version per concrete
type. The call ends up direct, with no dispatch cost.

Also shows `common func`, which is how Mux spells a constructor: a function that
belongs to the class rather than to an instance.

```bash
mux run main.mux
```
