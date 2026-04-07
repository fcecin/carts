# Study

## Task

Fix all `isNil(expr)` function-call syntax and `.isNil` (missing parens) to `.isNil()`.

## Scope

332 occurrences across 69 Nim files in `workspace/logos-delivery/`.

## Patterns found

1. `isNil(expr)` — function call syntax. Convert to `expr.isNil()`.
   - Includes `not isNil(expr)`, `if isNil(expr):`, nested parens
2. `.isNil` without `()` — method syntax missing parens. Add `()`.
   - Includes `expr.isNil:`, `expr.isNil and`, `expr.isNil\n`
3. `.isNil()` — already correct, leave alone.

## Steps

One skill handles all three patterns: **isnil-normalizer** (cached).
