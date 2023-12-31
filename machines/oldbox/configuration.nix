# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  # We need few volumes to be mounted before our system starts booting
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;

  home-manager.users.jankaifer.home.stateVersion = "22.05";

  networking.firewall.enable = false;

  # no root
  users.users.root.hashedPassword = "!";

  # Options
  custom = {
    cli-server.enable = true;
    common-workstation.enable = true;
    impermanence.enable = true;
    fck.enable = true;
    ssh-server.enable = true;
    ssh-keys-autogenerate.enable = true;

    options = {
      hostName = "oldbox";
    };
  };
}
