# isnil-normalizer

Normalizes Nim `isNil` calls to consistent method syntax with parentheses.

## Transformations

1. **Function call syntax**: `isNil(expr)` -> `expr.isNil()`
   - Handles: `isNil(x)`, `not isNil(x)`, `if isNil(x.y.z):`
   - Must correctly extract the full argument expression including dotted chains

2. **Method syntax without parens**: `expr.isNil` -> `expr.isNil()`
   - Only when NOT already followed by `(`
   - Handles: `x.isNil`, `x.y.isNil`, `not x.isNil`

3. **Already correct**: `expr.isNil()` — leave alone

## Exclusions

- Do NOT modify isNil inside comments (lines where isNil appears after `#`)
- Do NOT modify isNil inside string literals

## Verification

After transformation, a file should have:
- Zero occurrences of `isNil(` as a function call (not as `.isNil(`)
- Zero occurrences of `.isNil` not followed by `(`
- All isNil usages should be `.isNil()`
