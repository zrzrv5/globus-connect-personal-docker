#!/usr/bin/env bash
set -euo pipefail

# Default data dir inside container (mounted volume recommended)
DATA_DIR="${GCP_DATA_DIR:-$HOME/.globusonline}"
mkdir -p "$DATA_DIR"

# Redirect GCP to use this directory
export HOME
cd "$HOME"

# Pass all arguments to gcp
exec "$@"
