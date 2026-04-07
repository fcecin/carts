#!/usr/bin/env bash
# Critiques a completed workspace: writes a brutal, unforgiving critique.md with a star rating.
set -euo pipefail

CART_DIR="${1:?ERROR: cart directory not provided}"

echo "=== cart-critic init ==="
echo ""
echo "This will set up a critique run for the current work directory."
echo "The critic reads all workspace output (report.md, log.md, diffs)"
echo "and writes a brutal, honest critique.md with a star rating."
echo ""

if [ ! -d "workspace" ]; then
  echo "ERROR: No workspace/ directory. Nothing to critique." >&2
  exit 1
fi

if [ -f "workspace/critique.md" ]; then
  echo "critique.md already exists. Delete it first if you want a fresh critique."
  exit 0
fi

# Archive current task.md
if [ -f "task.md" ]; then
  n=1
  while [ -f "workspace/reviewed-task-${n}.md" ]; do
    n=$((n + 1))
  done
  cp task.md "workspace/reviewed-task-${n}.md"
  echo "Archived task.md -> workspace/reviewed-task-${n}.md"
fi

# Figure out cart path
CART_REL=""
if [[ "$CART_DIR" == */cartridges/* ]]; then
  CART_REL="${CART_DIR##*/cartridges/}"
fi

cat > task.md << TASK
# Task: Critique workspace

cartridge: ${CART_REL:-cart-critic}

Review this workspace thoroughly and write workspace/critique.md.
TASK

echo ""
echo "Wrote critique task.md"
echo ""
echo "Next: run 'golem run' to start the critique."
