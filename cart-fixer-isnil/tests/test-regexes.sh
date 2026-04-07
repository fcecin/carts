#!/usr/bin/env bash
set -euo pipefail

# Regression test for isNil verify regexes
# Tests that the regexes correctly detect violations and pass on clean files.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
errors=0
fail() { echo "FAIL: $1"; errors=$((errors + 1)); }

# --- Test against input files (should have violations) ---
for f in "$SCRIPT_DIR/data/input/"*.nim; do
  name=$(basename "$f")
  # func-call violations
  func_hits=$(grep -cP '(?<!\.)\bisNil\s*\(' "$f" 2>/dev/null || true)
  func_hits=${func_hits:-0}
  # no-parens violations
  noparen_hits=$(grep -cP '\.isNil\b(?!\s*\()' "$f" 2>/dev/null || true)
  noparen_hits=${noparen_hits:-0}

  # all input files should have at least one violation
  total=$((func_hits + noparen_hits))
  [ "$total" -gt 0 ] || fail "$name: expected violations in input, got 0"
done

# --- Test against expected files (should be clean) ---
for f in "$SCRIPT_DIR/data/expected/"*.nim; do
  name=$(basename "$f")
  # func-call: should be 0 (excluding comments and string literals)
  func_hits=$(grep -P '(?<!\.)\bisNil\s*\(' "$f" 2>/dev/null | grep -v '^\s*#' | grep -v 'echo\s*"' | wc -l || true)
  # no-parens: should be 0 (excluding comments and string literals)
  noparen_hits=$(grep -P '\.isNil\b(?!\s*\()' "$f" 2>/dev/null | grep -v '^\s*#' | grep -v 'echo\s*"' | wc -l || true)

  [ "$func_hits" -eq 0 ] || fail "$name (expected): $func_hits func-call violations remain"
  [ "$noparen_hits" -eq 0 ] || fail "$name (expected): $noparen_hits no-parens violations remain"
done

# --- Result ---
if [ "$errors" -eq 0 ]; then
  echo "PASS"
else
  echo "FAIL ($errors errors)"
fi
