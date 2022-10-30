{ ... }:

# Entry for configuration of my personal PC

{
  imports = [
    ../hardware/pearbox.nix
    ../nixos/common-configuration.nix
    ../nixos/personal-configuration.nix
  ];
}
