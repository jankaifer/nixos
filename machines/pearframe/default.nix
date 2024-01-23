{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules."framework-12th-gen-intel"
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "pearframe";
  system.stateVersion = "23.11";
  services.fwupd.enable = true;

  custom.system = {
    development.enable = true;
    gui.enable = true;
    home-manager.enable = true;
    impermanence.enable = true;
  };
}
