#!/usr/bin/env bash

exec nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=/etc/nixos/machines/jankaifer-iso/configuration.nix