#!/usr/bin/env bash
# APPENDS TO TASK. Adds a post-completion critique phase that writes a brutal critique.md with a star rating.
set -euo pipefail

CART_DIR="${1:?ERROR: cart directory not provided}"

echo "=== cart-critic init ==="
echo ""
echo "This appends a critique phase to the existing task.md."
echo "When the main task completes, the model will load cart-critic"
echo "and write a brutal, honest critique.md with a star rating."
echo ""

if [ ! -f "task.md" ]; then
  echo "ERROR: No task.md. Run the main cart-init first." >&2
  exit 1
fi

# Check if critic is already appended
if grep -q "cart-critic" task.md 2>/dev/null; then
  echo "cart-critic is already in task.md. Nothing to do."
  exit 0
fi

# Figure out cart path
CART_REL=""
if [[ "$CART_DIR" == */cartridges/* ]]; then
  CART_REL="${CART_DIR##*/cartridges/}"
fi

cat >> task.md << TASK

## After completion: critique

When the main task is fully complete (all scopes done, session report written),
load the cart-critic cartridge manifest from:
  \`<golem>/cartridges/${CART_REL}/manifest.md\`

Then follow its instructions to write workspace/critique.md.
Do not skip this step. The critique is part of the task.
TASK

echo "Appended critique phase to task.md"
echo ""
echo "The critic will run automatically after the main task completes."
