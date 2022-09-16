{ pkgs, ...}:

{
  imports =
    [
      # Auto-generated hardware configuration
      /etc/nixos/hardware-configuration.nix
      
      # My overrides for specific machine
      ./framework.nix
    ];
}