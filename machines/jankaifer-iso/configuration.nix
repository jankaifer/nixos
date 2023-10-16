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
    user = "pearman";
  };

  # Options
  custom = {
    fck.enable = true;
    gui.enable = true;
    iso.enable = true;
    vscode.enable = true;
    wifi-setup.enable = true;
    zsa.enable = true;
  };
}
