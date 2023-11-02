# Truth Table

3 examples

- `T` = True, `F` = False
- `p`, `q`, `r` are `boolean` variables
- Standard notation: `^` = `and`, `v` = `or`, `~` = `not`

| p | q | r | (p ∧ q) ∧ r  | (~p ∧ q) ∨ r  | ~(p ∨ ~q ∨ ~r) |
|---|---|---|--------------|---------------|----------------|
| T | T | T | T            | T             | F              |
| T | T | F | F            | F             | F              |
| T | F | T | F            | T             | F              |
| T | F | F | F            | F             | F              |
| F | T | T | F            | T             | T              |
| F | T | F | F            | T             | F              |
| F | F | T | F            | T             | F              |
| F | F | F | F            | F             | F              |