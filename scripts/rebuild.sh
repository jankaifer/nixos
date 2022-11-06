#!/usr/bin/env bash

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

if [ -n "$HOSTNAME" ]; then
    MACHINE_PATH="/etc/nixos/machines/$HOSTNAME"
    I_ARGS+=("-I" "nixpkgs=$MACHINE_PATH/nixpkgs")
    I_ARGS+=("-I" "nixos-config=$MACHINE_PATH/configuration.nix")
fi

echo nixos-rebuild "${I_ARGS[@]}" "${OTHER_ARGS[@]}"
exec nixos-rebuild "${I_ARGS[@]}" "${OTHER_ARGS[@]}"
