{ lib, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>
    ../../modules
  ];

  users.extraUsers.nixos.openssh.authorizedKeys.keys = import ../../modules/publicSshKeys.nix;

  # bzip2 compression takes loads of time with emulation, skip it.
  sdImage.compressImage = false;

  # Enable OpenSSH out of the box.
  services.openssh.enabled = true;
}
