{ inputs, config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "pearbox";
  system.stateVersion = "23.11";
  services.fwupd.enable = true;

  # Install nvidia drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
  };

  custom.system = {
    development.enable = true;
    gui.enable = true;
    home-manager.enable = true;
    impermanence.enable = true;
    steam.enable = true;
    user = "pearman";
  };
}
