# This file needs to be imported only in raspberry configs. It's not possible to toggle it with options.
{ config, lib, pkgs, ... }:

{
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix>
  ];
  # bzip2 compression takes loads of time with emulation, skip it.
  sdImage.compressImage = false;

  # When building on x86 machine, use emulation
  nixpkgs.hostPlatform.system = "aarch64-linux";

  custom = {
    cli-server.enable = true;
    common.enable = true;
    fck.enable = true;
    ssh-keys-autogenerate.enable = true;
    ssh-server.enable = true;
  };
}
