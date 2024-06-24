{ config, lib, ... }:

{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  networking.hostName = "jankaifer-iso";
  system.stateVersion = "24.05";

  # Make compression faster
  isoImage.squashfsCompression = "gzip -Xcompression-level 1";

  services.displayManager.autoLogin = lib.mkForce {
    enable = true;
    user = config.custom.system.user;
  };

  custom.system = {
    development.enable = true;
    gui.enable = true;
    home-manager.enable = true;
    impermanence.enable = true;
    sshd.enable = true;
    user = "jankaifer";
  };
}
