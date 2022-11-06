#!/usr/bin/env bash

set -euo pipefail

MODULES_PATH="/etc/nixos/modules"

exec "$MODULES_PATH/nixpkgs/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh" > "$MODULES_PATH/vscode/extensions.nix"