{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Nvidia protrietary drivers sometimes don't work on bleeding edge, so we might need to pin older kernel
  # boot.kernelPackages = pkgs.linuxPackages_6_6;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  nixpkgs.hostPlatform = "x86_64-linux";
  networking.hostName = "pearbox";
  system.stateVersion = "23.11";
  services.fwupd.enable = true;

  # Install nvidia drivers
  # services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl = {
    enable = true;
  };

  # hardware.nvidia = {
  #   package = config.boot.kernelPackages.nvidiaPackages.production;
  #   modesetting.enable = true;
  #   # this fixes issues with corrupted video output after suspend
  #   powerManagement.enable = true;
  #   # This means nvidia open source drivers (not nouveau), my 1080 is not supported
  #   open = false;
  # };

  ## Disable Nvidia
  boot.extraModprobeConfig = ''
    blacklist nouveau
    options nouveau modeset=0
  '';

  services.udev.extraRules = ''
    # Remove NVIDIA USB xHCI Host Controller devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c0330", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA USB Type-C UCSI devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x0c8000", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA Audio devices, if present
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x040300", ATTR{power/control}="auto", ATTR{remove}="1"
    # Remove NVIDIA VGA/3D controller devices
    ACTION=="add", SUBSYSTEM=="pci", ATTR{vendor}=="0x10de", ATTR{class}=="0x03[0-9]*", ATTR{power/control}="auto", ATTR{remove}="1"
  '';
  boot.blacklistedKernelModules = [ "nouveau" "nvidia" "nvidia_drm" "nvidia_modeset" ];

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
