{ pkgs, ... }:

{
  imports =
    [
      # Auto-generated hardware configuration
      /etc/nixos/hardware-configuration.nix
    ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
}
