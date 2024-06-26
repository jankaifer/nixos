{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  boot.kernelPackages = pkgs.linuxPackages_latest;
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "hydrogen";

  system.stateVersion = "24.05";
  custom.system = {
    sshd.enable = true;
    impermanence.enable = true;
    gui.enable = true;
    development.enable = true;
    home-manager.enable = true;
  };
}
