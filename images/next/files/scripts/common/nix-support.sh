#!/usr/bin/env bash

# Creates a '/nix' directory, so that
# the Nix package manager can be used

set -euo pipefail

NIX_DIR="/nix"

echo "Enabling Nix package manager support"

mkdir -p ${NIX_DIR}
