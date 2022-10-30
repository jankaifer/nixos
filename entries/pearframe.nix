{ pkgs, ... }:

# Entry for configuration of my personal Framework

{
  imports = [
    ../hardware/pearframe.nix
    ../nixos/configuration.nix
  ];
}
