# Test Results

## Files tested

1. `declare_lib.nim` — 3 `isNil(expr)` function calls converted to `expr.isNil()`
2. `keyfile.nim` — 4 `isNil(expr)` function calls converted to `expr.isNil()`
3. `waku.nim` — 1 `isNil(expr)` function call converted; 22 already-correct `.isNil()` left alone

## Verification

- `(?<!\.)isNil\(` — 0 matches (no function-call syntax remaining)
- `\.isNil([^(]|$)` — 0 matches (no method syntax without parens remaining)

## Result: PASS
