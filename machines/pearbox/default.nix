{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Nvidia protrietary drivers sometimes don't work on bleeding edge, so we might need to pin older kernel
  boot.kernelPackages = pkgs.linuxPackages_6_6;
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
    package = config.boot.kernelPackages.nvidiaPackages.production;
    modesetting.enable = true;
    # this fixes issues with corrupted video output after suspend
    powerManagement.enable = true;
    # This means nvidia open source drivers (not nouveau), my 1080 is not supported
    open = false;
  };

  custom.system = {
    development.enable = true;
    gui.enable = true;
    home-manager.enable = true;
    impermanence.enable = true;
    impermanence.persistHome = true;
    steam.enable = true;
    user = "pearman";
  };

  # There was shutter present in previous versions
  # environment.etc =
  #   let
  #     json = pkgs.formats.json { };
  #   in
  #   {
  #     "pipewire/pipewire.d/91-fix-shutters.conf".source = json.generate "91-fix-shutters.conf" {
  #       context.properties = {
  #         default.clock.rate = 192000;
  #         default.clock.quantum = 512;
  #         default.clock.min-quantum = 32;
  #         default.clock.max-quantum = 4096;
  #       };
  #     };
  #   };
}
