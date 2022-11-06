{ pkgs, config, ... }:
{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/machines/${config.networking.hostName}/nixpkgs"
    "nixos-config=/etc/nixos/machines/${config.networking.hostName}/configuration.nix"
  ];

  imports = [
    ./hardware-configuration.nix
    ../../hardware/framework.nix
    ../../modules
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  ## Enable swap on luks
  boot.initrd.luks.devices."luks-03537895-0d55-4d42-83b0-28f2c82e6273".device = "/dev/disk/by-uuid/03537895-0d55-4d42-83b0-28f2c82e6273";
  boot.initrd.luks.devices."luks-03537895-0d55-4d42-83b0-28f2c82e6273".keyFile = "/crypto_keyfile.bin";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  ## Host name
  networking.hostName = "pearframe";
}
