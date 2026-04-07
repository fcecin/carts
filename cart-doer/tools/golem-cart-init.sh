#!/usr/bin/env bash
# Initializes a work directory for a general-purpose codebase transformation task.
set -euo pipefail

CART_DIR="${1:?ERROR: cart directory not provided}"

echo "=== cart-doer init ==="
echo ""
echo "This sets up a work directory for a general-purpose codebase task."
echo "The doer cart can do anything: refactoring, migration, style changes,"
echo "pattern fixes, renaming, etc. It builds skills at runtime and caches"
echo "them for reuse."
echo ""

# Check for existing cache
GOLEM_DIR="$(cd "$CART_DIR/../../.." && pwd)"
CACHE_DIR="$GOLEM_DIR/cache/fcecin/carts/cart-doer"
if [ -f "$CACHE_DIR/index.md" ]; then
  skills=$(wc -l < "$CACHE_DIR/index.md")
  echo "Skill cache found: $skills cached skills available."
else
  echo "No skill cache yet. Skills will be built during the first run."
fi
echo ""

# Ask for task description first
echo "What do you want done to the codebase?"
echo "(Describe the task in as much detail as you want. One line is fine,"
echo " but more detail helps the doer build better skills.)"
echo ""
read -rp "> " TASK_DESC

echo ""

# Ask for target repo
echo "Where is the target codebase?"
echo "  Enter a local path, git URL, or 'skip' if material is already set up."
echo ""
read -rp "> " TARGET

REPO_NAME=""
case "$TARGET" in
  skip|"")
    echo "Skipping material setup."
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
fi

# Figure out cart path
CART_REL=""
if [[ "$CART_DIR" == */cartridges/* ]]; then
  CART_REL="${CART_DIR##*/cartridges/}"
fi

cat > task.md << TASK
# Task: $TASK_DESC

cartridge: ${CART_REL:-cart-doer}

## Target

The target codebase is in \`material/$REPO_NAME/\`.

## What to do

$TASK_DESC

## Setup

1. Copy the target into workspace:
   \`cp -r material/$REPO_NAME workspace/$REPO_NAME\`

2. Process each file according to the skills built for this task.

## Output

After processing, results are in:
- workspace/report.md
- workspace/suggestions.md
- workspace/log.md
TASK

echo ""
echo "Created task.md"
echo ""
echo "You can add additional materials to material/ (specs, docs, style guides)"
echo "and edit task.md to reference them or add more detail."
echo ""
echo "Next steps:"
echo "  1. Review task.md and customize if needed"
echo "  2. Run: golem run"
echo "  3. Paste the boot phrase when prompted"
