#!/usr/bin/env bash

set -euo pipefail

OTHER_ARGS=()
I_ARGS=()
HOSTNAME=""

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--hostname)
      HOSTNAME="$2"
      shift
      shift
      ;;
    *)
      OTHER_ARGS+=("$1")
      shift
      ;;
  esac
done

# Default OTHER_ARGS to "switch" if it's empty
if [ ${#OTHER_ARGS[@]} -eq 0 ]; then
  OTHER_ARGS=("switch")
fi

REPO_PATH="/etc/nixos"
MACHINE_PATH="$REPO_PATH/machines/$HOSTNAME"
I_ARGS+=("-I" "nixpkgs=$REPO_PATH/modules/nixpkgs")

echo 'NIX_SSHOPTS="-tt"' NIXOS_CONFIG="$MACHINE_PATH/configuration.nix" nixos-rebuild --target-host "$HOSTNAME.local" --use-remote-sudo "${I_ARGS[@]}" "${OTHER_ARGS[@]}"
NIX_SSHOPTS="-tt" NIXOS_CONFIG="$MACHINE_PATH/configuration.nix" nixos-rebuild --target-host "$HOSTNAME.local" --use-remote-sudo "${I_ARGS[@]}" "${OTHER_ARGS[@]}"

echo ssh "$HOSTNAME.local" 'sudo reboot'
ssh "$HOSTNAME.local" 'sudo reboot'
