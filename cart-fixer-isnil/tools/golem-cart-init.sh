#!/usr/bin/env bash
# Normalize Nim isNil calls to consistent .isNil() method syntax
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: golem-cart-init.sh <path-to-nim-codebase>"
  echo ""
  echo "Normalizes all isNil(expr) and .isNil to .isNil() in Nim files."
  exit 1
fi

TARGET="$1"

if [ ! -d "$TARGET" ]; then
  echo "Error: '$TARGET' is not a directory"
  exit 1
fi

cat > task.md <<EOF
# Task: Normalize isNil calls

cartridge: fcecin/carts/cart-fixer-isnil

## Target

Normalize all \`isNil\` usages in \`$TARGET\` to consistent
\`.isNil()\` method-call syntax with parentheses.
EOF

echo "Created task.md — run golem to start."
