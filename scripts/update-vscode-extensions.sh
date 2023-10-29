#!/usr/bin/env bash

set -euo pipefail

NIXOS_PATH="/persist/$HOME/dev/jankaifer/nixos"

exec "$NIXOS_PATH/modules/nixpkgs/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh" > "$NIXOS_PATH/modules/vscode/extensions.nix"
