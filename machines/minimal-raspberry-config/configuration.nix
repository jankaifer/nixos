{ lib, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix>
    ../../modules
  ];

  # bzip2 compression takes loads of time with emulation, skip it.
  sdImage.compressImage = false;

  custom = {
    ssh-server.enable = true;
    fck.enable = true;
  };
}
