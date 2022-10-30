{ ... }:

# Entry for configuration of my personal Framework

{
  imports = [
    ../hardware/pearframe.nix
    ../nixos/common-configuration.nix
    ../nixos/personal-configuration.nix
  ];
}
