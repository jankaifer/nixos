{ pkgs, ... }:

# Entry for configuration of my personal Framework

{
  imports = [
    ../hardware/pearframe.nix
    ../nixos/personal-configuration.nix
  ];
}
