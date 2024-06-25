{ pkgs, config, lib, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  system.stateVersion = "24.05";
  custom.system = {
    sshd.enable = true;
    impermanence.enable = true;
    gui.enable = true;
    development.enable = true;
    home-manager.enable = true;
  };
}
