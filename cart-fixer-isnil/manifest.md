# cart-fixer-isnil

depends: cart-code-processor

Normalizes all Nim `isNil` usages to consistent `.isNil()` method syntax
with parentheses. Fixes two deviation patterns:

1. **Function-call syntax**: `isNil(expr)` → `expr.isNil()`
2. **Missing parentheses**: `expr.isNil` → `expr.isNil()`

Already-correct `.isNil()` calls are left alone.

## When to use

Run this cart on any Nim codebase that mixes `isNil` call styles. The
normalized form `expr.isNil()` is the idiomatic Nim method-call syntax.

## Processing

Use the file walker (`walk init`, `walk next`, `walk done`) from
cart-code-processor. For each `.nim` file:

### Pre-scan

Run `grep -nP 'isNil' {file}`. If no matches, `walk skip` the file.

### Fix: function-call syntax

Find lines matching `(?<!\.)\bisNil\s*\(` (i.e. `isNil(` not preceded by `.`).

Transform `isNil(expr)` → `expr.isNil()`:
- Extract the full argument expression, handling dotted chains and nested
  parentheses (e.g. `isNil(x.y.z)` → `x.y.z.isNil()`).
- Preserve surrounding context: `not isNil(expr)` → `not expr.isNil()`,
  `if isNil(expr):` → `if expr.isNil():`.

### Fix: missing parentheses

Find lines matching `\.isNil\b(?!\s*\()` (i.e. `.isNil` not followed by `(`).

Append `()`: `expr.isNil` → `expr.isNil()`.

### Exclusions

- Do NOT modify `isNil` inside comments (after `#` on the line).
- Do NOT modify `isNil` inside string literals.

### Verification

After processing each file, verify:
- `grep -nP '(?<!\.)\bisNil\s*\(' {file}` — 0 matches (no function-call syntax)
- `grep -nP '\.isNil\b(?!\s*\()' {file}` — 0 matches (no missing parens)

If verification fails, re-examine and fix. Do not mark the file done
until it passes.

## Skipping instances

If a transformation would be unsafe (e.g. inside a macro definition,
template with `untyped` parameters, or code generation block), log the
instance to `workspace/suggestions.md` with file, line, snippet, and
reason for skipping.

## API safety

These transformations are purely syntactic — `.isNil()` is semantically
identical to `isNil(expr)` and `.isNil` in Nim. No API changes result
from this cart's fixes.
