{ inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules."framework-12th-gen-intel"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "pearframe";
  system.stateVersion = "23.11";
  services.fwupd.enable = true;

  custom.system = {
    development.enable = true;
    gui.enable = true;
  };
}
