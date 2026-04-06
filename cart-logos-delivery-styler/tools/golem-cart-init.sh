#!/usr/bin/env bash
set -euo pipefail

# golem-cart-init.sh for cart-logos-delivery-styler
#
# This script sets up a golem work directory for Nim style enforcement using
# the Status Nim style guide. It is called by `golem cart-init styler <dir>`.
#
# What it does:
#   1. Asks where the target Nim codebase is (local path or git URL)
#   2. Copies or clones the codebase into material/
#   3. Generates a task.md configured for this cartridge
#
# After running this script:
#   - Edit task.md to adjust the walk scope (which subdirectory to process)
#   - Edit task.md to set the nph path if it's in a non-standard location
#   - Optionally edit learnings.md to seed known exceptions
#   - Run `golem run` to start the style enforcement session
#
# Called by: golem cart-init <cart> <dir>
# CWD is already set to the work directory.
# $1 is the absolute path to this cartridge's directory.

CART_DIR="${1:?ERROR: cart directory not provided}"

echo "=== cart-logos-delivery-styler init ==="
echo ""
echo "This sets up a golem work directory for Nim style enforcement"
echo "using the Status Nim style guide."
echo ""
echo "It will:"
echo "  1. Ask where the target Nim codebase is (local path or git URL)"
echo "  2. Copy or clone the codebase into material/"
echo "  3. Generate a task.md configured for this cartridge"
echo ""
echo "After this script finishes:"
echo "  - Edit task.md to adjust the walk scope (which directory to process)"
echo "  - Run 'golem run' to start the style enforcement session"
echo ""
echo "TODO: This cart will include style tasks specific to the logos-delivery"
echo "project at some point."
echo ""
echo "HINT: task.md is very powerful — you can for example override the styler"
echo "to check a specific concern only and the LLM will figure it out."
echo ""

# Check if task.md already has a cartridge set
if grep -q "^cartridge:" task.md 2>/dev/null; then
  existing=$(grep "^cartridge:" task.md | head -1)
  if [ "$existing" != "cartridge:" ]; then
    echo "WARNING: task.md already has a cartridge set: $existing"
    echo "Skipping task.md update. Edit manually if needed."
    echo ""
  fi
fi

# Ask for the target repo
echo "Where is the target codebase?"
echo "  1. Enter a local path to copy into material/"
echo "  2. Enter a git URL to clone into material/"
echo "  3. Skip (material already set up)"
echo ""
read -rp "> " TARGET

REPO_NAME=""
case "$TARGET" in
  [3]|skip|"")
    echo "Skipping material setup."
    # Try to detect existing repo in material/
    for d in material/*/; do
      [ -d "$d" ] && REPO_NAME=$(basename "$d") && break
    done
    ;;
  http*|git@*|github.com*)
    REPO_NAME=$(basename "$TARGET" .git)
    echo "Cloning $TARGET into material/$REPO_NAME..."
    git clone --quiet "$TARGET" "material/$REPO_NAME"
    echo "Cloned."
    ;;
  *)
    if [ -d "$TARGET" ]; then
      REPO_NAME=$(basename "$TARGET")
      echo "Copying $TARGET into material/$REPO_NAME..."
      cp -r "$TARGET" "material/$REPO_NAME"
      echo "Copied."
    else
      echo "ERROR: $TARGET is not a directory or URL." >&2
      exit 1
    fi
    ;;
esac

if [ -z "$REPO_NAME" ]; then
  REPO_NAME="target-repo"
  echo "WARNING: Could not determine repo name. Using '$REPO_NAME' in task.md."
  echo "Edit task.md to fix paths if needed."
fi

# Figure out the cart's github path relative to cartridges/
# e.g. /home/user/golem/cartridges/fcecin/carts/cart-logos-delivery-styler
# We want: github.com/fcecin/carts/cart-logos-delivery-styler
CART_REL=""
if [[ "$CART_DIR" == */cartridges/* ]]; then
  CART_REL="${CART_DIR##*/cartridges/}"
fi

# Write task.md
cat > task.md << TASK
# Task: Style enforcement

cartridge: ${CART_REL:-cart-logos-delivery-styler}

## Target

The target codebase is in \`material/$REPO_NAME/\`.

## Environment

nph may be at \`~/.nimble/bin/nph\` or in the target repo's vendor directory.

## Setup

1. Copy the target directory into workspace:
   \`cp -r material/$REPO_NAME workspace/$REPO_NAME\`

2. Initialize the walker on the target scope:
   \`walk init workspace/$REPO_NAME\`

3. Process each file according to the loaded cartridges.

## Output

After the walk completes, report:
- How many files were modified vs skipped
- Summary of changes made per file
- Any items flagged but not fixed
TASK

echo ""
echo "Created task.md"
echo ""
echo "Next steps:"
echo "  1. Edit task.md to adjust the walk scope (which directory to process)"
echo "  2. Run: golem run"
echo "  3. Paste the boot phrase when prompted"
