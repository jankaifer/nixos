{ lib, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/sd-image-aarch64.nix>
    ../../modules
  ];

  users.extraUsers.nixos.openssh.authorizedKeys.keys = import ../../modules/publicSshKeys.nix;

  # bzip2 compression takes loads of time with emulation, skip it.
  sdImage.compressImage = false;

  # OpenSSH is forced to have an empty `wantedBy` on the installer system[1], this won't allow it
  # to be started. Override it with the normal value.
  # [1] https://github.com/NixOS/nixpkgs/blob/9e5aa25/nixos/modules/profiles/installation-device.nix#L76
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];

  # Enable OpenSSH out of the box.
  services.sshd.enabled = true;
}
