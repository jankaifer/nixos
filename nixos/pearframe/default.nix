{ inputs, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.framework."13-inch"."12th-gen-intel"
  ];

  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "pearframe";
  system.stateVersion = "23.11";

  custom = {
    development.enable = true;
    gui.enable = true;
  };
}
