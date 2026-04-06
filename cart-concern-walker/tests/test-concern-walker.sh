#!/usr/bin/env bash
set -euo pipefail

# Test: concern walker — init, next with verify, done, skip, reset, resume
# Self-contained. Creates a temp work dir, runs the tool, checks output.
# Last line is PASS or FAIL.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOOL="$SCRIPT_DIR/../tools/concern"
DATA="$SCRIPT_DIR/data"
TMPDIR=$(mktemp -d)
trap "rm -rf $TMPDIR" EXIT

cd "$TMPDIR"
mkdir -p workspace

errors=0
fail() { echo "FAIL: $1"; errors=$((errors + 1)); }

# --- Test 1: init ---
out=$("$TOOL" init "$DATA/test-concerns.txt")
echo "$out" | grep -q "Initialized: 4 concerns" || fail "init should find 4 concerns, got: $out"

# --- Test 2: next without file (no verify) ---
out=$("$TOOL" next)
echo "$out" | grep -q "CONCERN: Simple check" || fail "next should return first concern, got: $out"
# No VERIFY section since no file arg
echo "$out" | grep -q "VERIFY:" && fail "next without file should not run verify"

# --- Test 3: next with file (runs verify) ---
"$TOOL" reset > /dev/null
out=$("$TOOL" next "$DATA/sample.nim")
echo "$out" | grep -q "CONCERN: Simple check" || fail "next with file should show concern"
echo "$out" | grep -q "VERIFY:" || fail "next with file should run verify"
echo "$out" | grep -q "hello" || fail "verify should find 'hello' in sample.nim"

# --- Test 4: done ---
out=$("$TOOL" done)
echo "$out" | grep -q "3 concerns remaining" || fail "done should show 3 remaining, got: $out"
echo "$out" | grep -q "report.md" || fail "done should nag about report.md"

# --- Test 5: skip ---
out=$("$TOOL" next > /dev/null && "$TOOL" skip)
echo "$out" | grep -q "2 concerns remaining" || fail "skip should show 2 remaining, got: $out"

# --- Test 6: pipe in verify command ---
out=$("$TOOL" next "$DATA/sample.nim")
echo "$out" | grep -q "CONCERN: Pipe in command" || fail "should be at 'Pipe in command', got: $out"
echo "$out" | grep -q "VERIFY RESULT" || fail "pipe verify should produce output"
# head -3 sample.nim | grep -c "push" should return 1
echo "$out" | grep -q "1" || fail "pipe verify should find push in first 3 lines"

# --- Test 7: done + last concern ---
"$TOOL" done > /dev/null
out=$("$TOOL" next)
echo "$out" | grep -q "CONCERN: Trailing empty" || fail "should be at last concern, got: $out"
"$TOOL" done > /dev/null

# --- Test 8: DONE after all ---
out=$("$TOOL" next)
echo "$out" | grep -q "DONE" || fail "should be DONE after all concerns, got: $out"

# --- Test 9: status ---
out=$("$TOOL" status)
echo "$out" | grep -q "Processed: 3" || fail "status should show 3 processed, got: $out"
echo "$out" | grep -q "Skipped: 1" || fail "status should show 1 skipped, got: $out"

# --- Test 10: reset ---
out=$("$TOOL" reset)
echo "$out" | grep -q "4 concerns" || fail "reset should show 4 concerns, got: $out"
out=$("$TOOL" next)
echo "$out" | grep -q "Simple check" || fail "after reset, next should return first concern"

# --- Test 11: resume (init refuses to overwrite) ---
out=$("$TOOL" init "$DATA/test-concerns.txt")
echo "$out" | grep -q "RESUMING" || fail "init on existing state should RESUME, got: $out"

# --- Test 12: init --force ---
out=$("$TOOL" init "$DATA/test-concerns.txt" --force)
echo "$out" | grep -q "Initialized: 4" || fail "init --force should reinitialize, got: $out"

# --- Test 13: log.md was written ---
[ -f workspace/log.md ] || fail "log.md should exist"
grep -q "\[concern-script\]" workspace/log.md || fail "log.md should have concern-script entries"

# --- Result ---
if [ "$errors" -eq 0 ]; then
  echo "PASS"
else
  echo "FAIL ($errors errors)"
fi
