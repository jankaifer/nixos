{ config, pkgs, ... }:

{
  imports =
    [
      # Include the results of the hardware scan.
      # The configuration itself can change though, we won't keep it in git.
      ./hardware-configuration.nix
    ];

  # Fixup hardware-configuration.nix
  boot.initrd.kernelModules = [
    "dm-snapshot"
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
  };

  networking.hostName = "pearcloud";

  # The server is not in Prague but it will make things easier
  time.timeZone = "Europe/Prague";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkbOptions in tty.
  # };

  environment.systemPackages = with pkgs; [
    vim
    wget
  ];

  services.openssh.enable = true;
  users = {
    mutableUsers = false;
    users.pearman = {
      isNormalUser = true;
      description = "Jan Kaifer";
      extraGroups = [
        "wheel"
        "networkmanage"
        "video"
        "docker"
        "adbusers"
        "lxd"
      ];

      # Password file doesn't work for some reason
      password = "Tackiness-Staple-Ivory6";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHVIfXNuROWZRJhqcEGW9eohIH5Fg3PblefvMu+JaNw jan@kaifer.cz"
      ];
    };
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  system.copySystemConfiguration = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.05"; # Did you read the comment?
}
