{ lib, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "jankaifer-iso";
  system.stateVersion = "24.05";

  custom.system = {
    # development.enable = true;
    # gui.enable = true;
    # home-manager.enable = true;
    user = "jankaifer";

  };
}
