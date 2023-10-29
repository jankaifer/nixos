{ pkgs, config, lib, ... }:
let gvariant = lib.hm.gvariant; in
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
  networking.hostName = "pearbox";

  networking.firewall.enable = false;

  # Install nvidia drivers
  services.xserver.videoDrivers = [ "nvidia" ];
  # services.xserver.videoDrivers = [ "nouveau" ];
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;

  # Options
  custom = {
    cli-workstation.enable = true;
    common-workstation.enable = true;
    impermanence.enable = true;
    fck.enable = true;
    games.enable = true;
    gui.enable = true;
    gui.idleDelay = 0;
    ssh-server.enable = true;
    vscode.enable = true;
    wifi-setup.enable = true;
    zsa.enable = true;

    options = {
      username = "pearman";
      wallpaper-uri = "file://" + ../../wallpapers/space.jpg;
    };
  };
}
