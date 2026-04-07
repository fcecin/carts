#!/usr/bin/env bash
set -euo pipefail

# golem-cart-init.sh for cart-rescuer
# CWD is the work directory. $1 is this cartridge's directory.

CART_DIR="${1:?ERROR: cart directory not provided}"

echo "=== cart-rescuer init ==="
echo ""
echo "This will set up a rescue run for the current work directory."
echo "It archives the current task.md and writes a new one that invokes"
echo "the rescuer cartridge."
echo ""

# Check there's something to rescue
if [ ! -d "workspace" ]; then
  echo "ERROR: No workspace/ directory. Nothing to rescue." >&2
  exit 1
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

# Write rescue task
cat > task.md << TASK
# Task: Rescue workspace

cartridge: ${CART_REL:-cart-rescuer}

Review this workspace. A previous run failed, was incomplete, or produced
low-quality results. Assess the damage, preserve good work, revert bad work,
and write a new task.md for the next productive run.

Check workspace/reviewed-task-*.md for the original intent.
TASK

echo ""
echo "Wrote rescue task.md"
echo ""
echo "Next: run 'golem run' to start the rescue analysis."
