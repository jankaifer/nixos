{ ... }:

# Entry for configuration of my work Framework

{
  imports = [
    ../hardware/vercelframe.nix
    ../nixos/common-configuration.nix
    ../nixos/work-configuration.nix
  ];
}
