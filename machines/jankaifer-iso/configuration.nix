{ pkgs, config, ... }:
{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/modules/nixpkgs"
    "nixos-config=/etc/nixos/machines/${config.networking.hostName}/configuration.nix"
  ];

  imports = [
    ../../modules/nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix
  ];

  # Host name
  networking.hostName = "jankaifer-iso";

  # Make compression faster
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";
}
