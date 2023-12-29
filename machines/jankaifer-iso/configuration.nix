{ config, lib, pkgs, ... }:
{
  imports = [
    ../../modules/nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix
    ../../modules
  ];

  # Host name
  networking.hostName = "jankaifer-iso";

  # Make compression faster
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  services.xserver.displayManager.autoLogin = lib.mkForce {
    enable = true;
    user = config.custom.options.username;
  };

  # Options
  custom = {
    cli-server.enable = true;
    common.enable = true;
    fck.enable = true;
    ssh-keys-autogenerate.enable = true;
    ssh-server.enable = true;

    options = {
      hostName = "jankaifer-iso";
    };
  };
}
