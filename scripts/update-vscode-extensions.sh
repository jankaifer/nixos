#!/usr/bin/env bash

set -euo pipefail

NIXOS_PATH="/persist/$HOME/dev/jankaifer/nixos"
EXTENSION_CONF="$NIXOS_PATH/modules/home-manager-custom/custom/vscode/extensions.nix"
# EXTENSION_CONF="$NIXOS_PATH/modules/vscode/extensions.nix"

exec "$NIXOS_PATH/modules/nixpkgs/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh" > "$EXTENSION_CONF"
