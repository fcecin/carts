#!/usr/bin/env bash
# Set up a work directory for cart-daemon: install or remove a system service
set -euo pipefail

echo "=== cart-daemon ==="
echo ""
echo "Describe the service you want installed or removed."
echo "Be specific: what it does, when it runs, what commands it invokes."
echo ""
echo "Examples:"
echo "  Install a cron job that runs 'golem clauder --dir ~/writer' daily at 8am"
echo "  Remove the systemd timer called my-backup.timer"
echo "  Install a user systemd service that runs a script on boot"
echo ""
read -r -p "Describe the service: " SERVICE_DESC

if [ -z "$SERVICE_DESC" ]; then
  echo "No description given. Aborting." >&2
  exit 1
fi

echo ""
read -r -p "Install or remove? [install/remove]: " ACTION
ACTION="${ACTION:-install}"

if [ "$ACTION" != "install" ] && [ "$ACTION" != "remove" ]; then
  echo "Must be 'install' or 'remove'. Aborting." >&2
  exit 1
fi

mkdir -p workspace

cat > task.md << EOF
# Daemon task

Load cart-daemon.

## Action

${ACTION}

## Service description

${SERVICE_DESC}
EOF

echo ""
echo "Done. task.md written."
echo "Review it, then run 'golem run' to execute."
