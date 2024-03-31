{ config, pkgs, ... }:

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

  environment.etc =
    let
      json = pkgs.formats.json { };
    in
    {
      "pipewire/pipewire.d/91-fix-shutters.conf".source = json.generate "91-fix-shutters.conf" {
        context.properties = {
          default.clock.rate = 192000;
          default.clock.quantum = 512;
          default.clock.min-quantum = 32;
          default.clock.max-quantum = 4096;
        };
      };
    };
}
