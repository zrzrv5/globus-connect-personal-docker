#!/usr/bin/env bash
set -euo pipefail

# Default data dir inside container (mounted volume recommended)
DATA_DIR="${GCP_DATA_DIR:-$HOME/.globusonline}"

# Ensure the config directory exists and has correct permissions
mkdir -p "$DATA_DIR"
mkdir -p "$DATA_DIR/lta"

# Fix ownership if running as root (shouldn't happen, but just in case)
if [ "$(id -u)" -eq 0 ]; then
    chown -R gcp:gcp "$DATA_DIR"
    exec su gcp -c "$0 $*"
fi

# Ensure we can write to the config directory
if [ ! -w "$DATA_DIR" ]; then
    echo "ERROR: Cannot write to config directory: $DATA_DIR"
    echo "Please ensure the mounted volume has correct permissions:"
    echo "  sudo chown -R 10001:10001 /path/to/your/config/directory"
    exit 1
fi

# Set proper environment
export HOME
cd "$HOME"

# Pass all arguments to gcp
exec "$@"
