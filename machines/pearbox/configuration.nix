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

  # Root needs to have correct permissions otherwise openssh will complain and won't work
  fileSystems."/".options = [ "mode=755" ];

  networking.firewall.enable = false;

  # Install nvidia drivers
  # services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.videoDrivers = [ "nouveau" ];
  hardware.opengl.enable = true;
  hardware.nvidia = {
    # package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;

    # prime = {
    #   sync.enable = true;

    #   # Make sure to use the correct Bus ID values for your system!
    #   nvidiaBusId = "PCI:01:00:0";
    #   intelBusId = "PCI:00:01:0";
    # };

    # forceFullCompositionPipeline = true;
  };


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
      hostName = "pearbox";
      wallpaper-uri = "file://" + ../../wallpapers/space.jpg;
    };
  };
}
