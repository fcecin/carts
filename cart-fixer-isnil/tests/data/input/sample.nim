# Test file for isnil-normalizer
# Tests all three patterns: function-call, missing parens, already correct

import std/options

type Foo = ref object
  bar: ref int
  baz: string

# Pattern 1: function-call syntax -> should become expr.isNil()
proc checkA(f: Foo) =
  if isNil(f):
    echo "f is nil"
  if not isNil(f.bar):
    echo "bar exists"
  let x = isNil(f)

# Pattern 2: missing parens -> should become .isNil()
proc checkB(f: Foo) =
  if f.isNil:
    echo "f is nil"
  if not f.bar.isNil:
    echo "bar is nil"
  let y = f.isNil and true

# Pattern 3: already correct -> leave alone
proc checkC(f: Foo) =
  if f.isNil():
    echo "f is nil"
  if not f.bar.isNil():
    echo "bar is nil"

# Edge case: isNil in comments should NOT be changed
# isNil(f) is the old style
# f.isNil is also old style

# Edge case: isNil in strings should NOT be changed
proc checkD() =
  echo "use isNil(x) to check"
  echo "or x.isNil works too"
