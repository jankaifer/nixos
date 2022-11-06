{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # We need few volumes to be mounted before our system starts booting
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/persistent".neededForBoot = true;

  # Host name
  networking.hostName = "vercelframe";

  # Options
  custom = {
    framework.enable = true;
    gui.enable = true;
    real-vnc-viewer.enable = true;
    zsa.enable = true;
  };
}
