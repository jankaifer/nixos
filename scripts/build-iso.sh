#!/usr/bin/env bash

set -euo pipefail

exec nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=/etc/nixos/machines/jankaifer-iso/configuration.nix