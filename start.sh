#!/bin/bash

# MongoDB on Kind - Quick Launcher
# Simple entry point for the interactive learning environment

echo "🎓 Welcome to MongoDB on Kind - Kubernetes Learning Lab!"
echo
echo "Starting the interactive menu system..."
echo

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Launch the interactive menu
exec "$SCRIPT_DIR/scripts/interactive-menu.sh"
