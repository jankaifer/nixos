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

  # Root needs to have correct permissions otherwise openssh will complain and won't work
  # fileSystems."/".options = [ "mode=755" ];

  home-manager.users.jankaifer.home.stateVersion = "22.05";

  # networking.firewall.enable = false;

  # Options
  custom = {
    # cli-server.enable = true;
    # common-workstation.enable = true;
    impermanence.enable = true;
    fck.enable = true;
    ssh-server.enable = true;
    ssh-keys-autogenerate.enable = true;

    options = {
      hostName = "oldbox";
    };
  };

  # DEBUG

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.settings.trusted-users = [ config.custom.options.username ];

  networking.hostName = config.custom.options.hostName;

  console = {
    font = "ter-i32b";
    packages = with pkgs; [ terminus_font ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  users = {
    mutableUsers = false;
    users."${config.custom.options.username}" = {
      isNormalUser = true;
      description = "Jan Kaifer";
      extraGroups = [
        "wheel"
        "networkmanage"
        "video"
        "docker"
        "adbusers"
        "lxd"
      ];

      password = "pass";
    };
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    grub.useOSProber = false;
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
}
