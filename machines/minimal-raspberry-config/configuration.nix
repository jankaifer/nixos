{ lib, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix>
    ../../modules
  ];

  # bzip2 compression takes loads of time with emulation, skip it.
  sdImage.compressImage = false;

  custom = {
    cli-server.enable = true;
    common.enable = true;
    fck.enable = true;
    ssh-server.enable = true;
  };
}
