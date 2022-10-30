{ pkgs, ... }:

# Entry for configuration of my work Framework

{
  imports = [
    ../hardware/vercelframe.nix
    ../nixos/work-configuration.nix
  ];
}
