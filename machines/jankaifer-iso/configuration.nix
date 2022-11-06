{ pkgs, config, ... }:
{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/machines/${config.networking.hostName}/nixpkgs"
    "nixos-config=/etc/nixos/machines/${config.networking.hostName}/configuration.nix"
  ];

  imports = [
    ./nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix
    ../../modules
  ];

  # Host name
  networking.hostName = "jankaifer-iso";
}
