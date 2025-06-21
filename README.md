# css-scheme
Structuring CSS with scheme, it produces **no side effects** and does not modify any external state.
e.g.
```scheme
(display
  (css
    (body (:not p) =>
      [#:color red])
    (@keyframes test =>
      [from => [#:background red]
       to   => [#:background yellow]])))
```
This macro does not check whether the syntax is correct. This macro is a wrapper of the function `css-transform`. The above example can be expressed as:
```scheme
(display
  (css-transform
    '(body (:not p) =>
      [#:color red])
    '(@keyframes test =>
      [from => [#:background red]
       to   => [#:background yellow]])))
```
