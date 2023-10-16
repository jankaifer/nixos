{ lib, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix>
    ../../modules
  ];

  users.extraUsers.nixos.openssh.authorizedKeys.keys = import ../../modules/publicSshKeys.nix;

  # bzip2 compression takes loads of time with emulation, skip it.
  sdImage.compressImage = false;

  # Enable OpenSSH out of the box.
  services.openssh.enable = true;
}
