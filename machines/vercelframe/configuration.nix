{ pkgs, config, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # We need few volumes to be mounted before our system starts booting
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/".neededForBoot = true;
  fileSystems."/home".neededForBoot = true;

  # Host name
  networking.hostName = "vercelframe";

  networking.firewall.enable = false;

  # Wallpaper
  home-manager.users.pearman.dconf.settings."org/gnome/desktop/background".picture-uri = "file://" + ../../wallpapers/vercel-pyramid-4k.png;

  # Options
  custom = {
    erase-root.enable = true;
    fck.enable = true;
    framework.enable = true;
    gui.enable = true;
    real-vnc-viewer.enable = true;
    vscode.enable = true;
    work.enable = true;
    zsa.enable = true;
  };
}
