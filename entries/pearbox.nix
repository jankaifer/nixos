{ pkgs, ... }:

# Entry for configuration of my personal PC

{
  imports = [
    ../hardware/pearbox.nix
    ../nixos/configuration.nix
  ];
}
