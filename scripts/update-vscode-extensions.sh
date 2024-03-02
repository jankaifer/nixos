#!/usr/bin/env bash

set -euo pipefail

NIXOS_PATH="/persist/$HOME/dev/jankaifer/nixos"
EXTENSION_CONF="$NIXOS_PATH/modules/home-manager/custom/vscode/extensions.nix"
UPDATE_SCRIPT_URL="https://raw.githubusercontent.com/NixOS/nixpkgs/master/pkgs/applications/editors/vscode/extensions/update_installed_exts.sh"

tmpfile=$(mktemp)

curl -s "$UPDATE_SCRIPT_URL" -o $tmpfile

# Make the script executable
chmod +x $tmpfile

# Run the script
"$tmpfile" > "$EXTENSION_CONF"

# Clean up
rm $tmpfile