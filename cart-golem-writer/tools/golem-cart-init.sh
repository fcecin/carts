#!/usr/bin/env bash
# Set up a golem-writer work directory for automated essay publishing
set -euo pipefail

CART_DIR="$(cd "$(dirname "$0")/.." && pwd)"

echo "=== cart-golem-writer ==="
echo ""
echo "This cart writes essays about the golem system."
echo "It needs a work directory with:"
echo "  - material/  containing the blog archive (previous articles)"
echo "  - task.md    describing where to find ideas and how to publish"
echo ""

# Blog archive source
read -r -p "Path to blog archive (git repo or directory with .md articles): " BLOG_PATH
if [ -z "$BLOG_PATH" ]; then
  echo "No archive path given. Starting with empty archive."
  mkdir -p material
else
  if [ -d "$BLOG_PATH/.git" ]; then
    echo "Cloning blog archive..."
    git clone "$BLOG_PATH" material/blog
  elif [ -d "$BLOG_PATH" ]; then
    echo "Copying blog archive..."
    cp -r "$BLOG_PATH" material/blog
  else
    echo "Error: $BLOG_PATH is not a directory" >&2
    exit 1
  fi
fi

# Creator's social feed
read -r -p "Creator's Twitter/X handle (or empty to skip): " TWITTER_HANDLE

# Publishing method
echo ""
echo "Publishing methods:"
echo "  1. Git repo (commit and push a markdown file)"
echo "  2. Local directory (write file for manual review)"
read -r -p "Choose [1/2]: " PUB_METHOD

PUB_REPO=""
PUB_DIR=""
if [ "$PUB_METHOD" = "1" ]; then
  read -r -p "Git repo URL for publishing: " PUB_REPO
elif [ "$PUB_METHOD" = "2" ]; then
  read -r -p "Local directory for articles: " PUB_DIR
fi

# Write task.md
cat > task.md << TASK
# Writer task

Load cart-golem-writer.

## Idea sources

### The golem installation
Read the entire golem installation. The cart manifest has the full protocol.

### Blog archive
Previous articles are in material/blog/

TASK

if [ -n "$TWITTER_HANDLE" ]; then
  cat >> task.md << TASK
### Creator's public activity
Read recent posts from: https://x.com/$TWITTER_HANDLE
Use fragments as seeds for Layer 2 and Layer 3 searches.

TASK
fi

cat >> task.md << TASK
## Publishing
TASK

if [ "$PUB_METHOD" = "1" ] && [ -n "$PUB_REPO" ]; then
  cat >> task.md << TASK

Publish by committing the article to: $PUB_REPO
Filename format: YYYY-MM-DD-short-title.md
Commit, push. The article is live when pushed.
TASK
elif [ -n "$PUB_DIR" ]; then
  cat >> task.md << TASK

Write the article to: $PUB_DIR
Filename format: YYYY-MM-DD-short-title.md
Do not push or publish — the operator will review manually.
TASK
else
  cat >> task.md << TASK

Write the article to workspace/articles/
Filename format: YYYY-MM-DD-short-title.md
The operator will publish manually.
TASK
fi

mkdir -p workspace

echo ""
echo "Done. Work directory ready."
echo "Run 'golem run' to write the first article."
echo "Run 'golem clauder' for unattended operation."
