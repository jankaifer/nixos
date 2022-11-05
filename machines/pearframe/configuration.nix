{ ... }:
{
  imports = [
    ../hardware/common.nix
    ../hardware/framework.nix

    ../nixos/common-configuration.nix
    ../nixos/personal-configuration.nix
  ];

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
