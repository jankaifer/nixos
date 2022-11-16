{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  # Weird system freezes were hapenning on 6.0
  # Gnome is broken on 5.15
  # Anything below 5.12 doesn't support my wifi
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # We need few volumes to be mounted before our system starts booting
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/".neededForBoot = true;
  fileSystems."/home".neededForBoot = true;

  # Host name
  networking.hostName = "pearframe";

  # Options
  custom = {
    erase-root.enable = true;
    fck.enable = true;
    framework.enable = true;
    games.enable = true;
    gui.enable = true;
    real-vnc-viewer.enable = true;
    vscode.enable = true;
    zsa.enable = true;
  };
}
