#!/usr/bin/env bash
# Extracts skills from a completed cart-doer workspace and packages them as a standalone cart.
set -euo pipefail

CART_DIR="${1:?ERROR: cart directory not provided}"
GOLEM_DIR="$(golem dir)"
CACHE_DIR="$GOLEM_DIR/cache/fcecin/carts/cart-doer"

echo "=== cart-meta-doer ==="
echo ""
echo "This extracts skills from a completed cart-doer run and launches"
echo "a golem session to polish them into a publishable cart."
echo ""

# Check we're in a workspace that has doer evidence
if [ ! -d "workspace" ]; then
  echo "ERROR: No workspace/ found. Run this on a completed doer work directory." >&2
  exit 1
fi

if [ ! -f "workspace/skill-map.md" ]; then
  echo "ERROR: No workspace/skill-map.md found. Is this a completed doer workspace?" >&2
  exit 1
fi

# Check cache exists
if [ ! -f "$CACHE_DIR/index.md" ]; then
  echo "ERROR: No doer cache found at $CACHE_DIR" >&2
  exit 1
fi

# Extract skills used from skill-map.md
# Skill-map has lines like: | 1. Normalize isNil calls | isnil-normalizer | BUILD |
skills=()
while IFS= read -r line; do
  # Extract skill name from pipe-separated table rows
  skill=$(echo "$line" | awk -F'|' '{print $3}' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  if [ -n "$skill" ] && [ "$skill" != "Skill" ] && [ "$skill" != "---" ]; then
    # Only include if it exists in cache
    if [ -d "$CACHE_DIR/$skill" ]; then
      skills+=("$skill")
    fi
  fi
done < "workspace/skill-map.md"

if [ ${#skills[@]} -eq 0 ]; then
  echo "ERROR: No cached skills found from skill-map.md" >&2
  exit 1
fi

echo "Skills found in workspace: ${skills[*]}"
echo ""

# Ask for cart name
echo "Cart name? (e.g. cart-isnil-normalizer)"
read -rp "> " CART_NAME

# Build the cart inside the existing workspace
OUT="workspace/$CART_NAME"
mkdir -p "$OUT/tools"

# Copy all skill files
for skill in "${skills[@]}"; do
  skill_dir="$CACHE_DIR/$skill"

  mkdir -p "$OUT/skills/$skill"
  cp -r "$skill_dir"/* "$OUT/skills/$skill/" 2>/dev/null || true

  echo "  Packed: $skill"
done

# Copy evidence from this workspace
mkdir -p "$OUT/evidence"
for f in study.md skill-map.md test-results.md report.md; do
  [ -f "workspace/$f" ] && cp "workspace/$f" "$OUT/evidence/"
done
echo "  Copied workspace evidence"

# Copy test data from this workspace
if [ -d "workspace/test" ]; then
  mkdir -p "$OUT/tests/data"
  cp -r workspace/test/* "$OUT/tests/data/" 2>/dev/null || true
  echo "  Copied test data"
fi

# Stub manifest (Claude will rewrite)
cat > "$OUT/manifest.md" << MANIFEST
# $CART_NAME

## STUB — to be rewritten by golem session

Skills: ${skills[*]}

Check workspace/$CART_NAME/evidence/skill-map.md for which installed
carts were used — those become depends: lines in the final manifest.
MANIFEST

# Learnings
cat > "$OUT/learnings.md" << 'LEARN'
# Learnings

## Accepted

## Rejected

## Clarifications
LEARN

echo ""
echo "Raw cart assembled: $OUT/"
echo ""

# Write task.md for the meta-doer golem session
CART_REL=""
if [[ "$CART_DIR" == */cartridges/* ]]; then
  CART_REL="${CART_DIR##*/cartridges/}"
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

cat > task.md << TASK
# Task: Promote doer skills to a standalone cart

cartridge: ${CART_REL:-cart-meta-doer}

## Target

The raw cart materials are in \`workspace/$CART_NAME/\`.
The skill definitions are in \`workspace/$CART_NAME/skills/\`.
The doer evidence is in \`workspace/$CART_NAME/evidence/\`.
Polish them into a publishable cart.
TASK

echo ""
echo "Launching golem clauder..."
echo "  (Pass --claude-args='--dangerously-skip-permissions' for unattended mode)"
echo ""
echo "Or paste the boot phrase manually: $(golem boot)"
echo ""

exec golem clauder --idle 30
