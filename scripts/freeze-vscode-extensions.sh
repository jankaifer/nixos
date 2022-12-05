#!/usr/bin/env bash

set -euo pipefail

NIXOS_PATH="/persist/home/pearman/dev/jankaifer/nixos"

exec "$NIXOS_PATH/scripts/print-frozen-vscode-extensions.sh" > "$NIXOS_PATH/modules/vscode/extensions.nix"