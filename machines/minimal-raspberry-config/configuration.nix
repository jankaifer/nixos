{ lib, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64-installer.nix>
    ../../modules
  ];

  # bzip2 compression takes loads of time with emulation, skip it.
  sdImage.compressImage = false;

  networking.hostName = "raspberry-minimal-install";

  # When building on x86 machine, use emulation
  nixpkgs.buildPlatform.system = "aarch64-linux";
  nixpkgs.hostPlatform.system = "aarch64-linux";

  custom = {
    cli-server.enable = true;
    common.enable = true;
    fck.enable = true;
    ssh-keys-autogenerate.enable = true;
    ssh-server.enable = true;
  };
}
