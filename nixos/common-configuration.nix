{ config, pkgs, ... }:

with builtins;
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };

  home-manager = fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    ref = "release-22.05";
  };

  toRelativePath = relativePath: toPath (../. + "/${relativePath}");

  # My secrets are living in different repository that is not public:
  # - https://gitlab.com/JanKaifer/nixos-secrets
  secrets = import ../secrets moduleArgs;

  moduleArgs = {
    inherit config pkgs toRelativePath unstable secrets;
  };
in
{
  imports =
    [
      # Initialize home-manager
      (import "${home-manager}/nixos")


      # Other configs
      (import ../scripts moduleArgs)
      (import ../home-manager moduleArgs)

      ./audio.nix
      ./systemPackages.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.useOSProber = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Add support for moonlander
  # system option is outdated
  # hardware.keyboard.zsa.enable = true;
  services.udev.extraRules = ''
    # Rules for Oryx web flashing and live training
    KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0664", GROUP="plugdev"
    KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0666", GROUP="plugdev"

    # Legacy rules for live training over webusb (Not needed for firmware v21+)
    # Rule for all ZSA keyboards
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", GROUP="plugdev"
    # Rule for the Moonlander
    SUBSYSTEM=="usb", ATTR{idVendor}=="3297", ATTR{idProduct}=="1969", GROUP="plugdev"
    # Rule for the Ergodox EZ
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="1307", GROUP="plugdev"
    # Rule for the Planck EZ
    SUBSYSTEM=="usb", ATTR{idVendor}=="feed", ATTR{idProduct}=="6060", GROUP="plugdev"

    # Wally Flashing rules for the Ergodox EZ
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", ENV{ID_MM_DEVICE_IGNORE}="1"
    ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789A]?", ENV{MTP_NO_PROBE}="1"
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789ABCD]?", MODE:="0666"
    KERNEL=="ttyACM*", ATTRS{idVendor}=="16c0", ATTRS{idProduct}=="04[789B]?", MODE:="0666"

    # Wally Flashing rules for the Moonlander and Planck EZ
    SUBSYSTEMS=="usb", ATTRS{idVendor}=="0483", ATTRS{idProduct}=="df11", MODE:="0666", SYMLINK+="stm32_dfu"
  '';

  # Networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "cs_CZ.utf8";
    LC_IDENTIFICATION = "cs_CZ.utf8";
    LC_MEASUREMENT = "cs_CZ.utf8";
    LC_MONETARY = "cs_CZ.utf8";
    LC_NAME = "cs_CZ.utf8";
    LC_NUMERIC = "cs_CZ.utf8";
    LC_PAPER = "cs_CZ.utf8";
    LC_TELEPHONE = "cs_CZ.utf8";
    LC_TIME = "cs_CZ.utf8";
  };

  console = {
    font = "ter-i32b";
    useXkbConfig = true;
    earlySetup = true;
    packages = with pkgs; [ terminus_font ];
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Modify GNOME default settings: https://discourse.nixos.org/t/gnome3-settings-via-configuration-nix/5121
  # Source for these modifications: https://guides.frame.work/Guide/Fedora+36+Installation+on+the+Framework+Laptop/108#s655
  services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
    [org.gnome.mutter]
    experimental-features=[]
  '';

  # Touchpad configs
  services.xserver.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
    touchpad.additionalOptions = ''MatchIsTouchpad "on"'';
  };

  # Configure keymap in X11
  services.xserver = {
    layout = "fck";
    extraLayouts.fck = {
      description = "Fancy czech keyboard";
      languages = [ "en" "cs" ];
      symbolsFile =
        let
          commit = "365095d7d5c9d912b1945ddd1039f787dc72d186";
        in
        builtins.fetchurl {
          url = "https://gitlab.com/JanKaifer/fck/-/raw/${commit}/fck";
        };
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Make SUDO to remember fingerprint/password for 30 minutes
  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=30
  '';

  # Setup user
  users.mutableUsers = false;
  users.users.pearman = {
    isNormalUser = true;
    description = "Jan Kaifer";
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "docker"
      "adbusers"
      "lxd"
    ];
    hashedPassword = secrets.hashedPassword;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Use ZSH
  users.defaultUserShell = pkgs.zsh;

  programs = {
    # To allow configuration of gnome
    dconf.enable = true;

    # More info on wiki: https://nixos.wiki/wiki/Steam
    steam.enable = true;

    zsh = {
      enable = true;
      enableBashCompletion = true;
      promptInit = ''
        eval "$(direnv hook zsh)"
      '';
      shellAliases =
        let
          zsh = "${pkgs.zsh}/bin/zsh";
        in
        {
          rebuild = "sudo nixos-rebuild switch |& nom";
        };
    };
  };

  fonts.fonts = with pkgs; [
    fira-code
    fira-code-symbols
    nerdfonts
    siji
  ];

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };

  ## Force Chromium based apps to render using wayland
  ## It is sadly not ready yet - electron apps will start missing navbars and they are still blurry 
  # environment.sessionVariables.NIXOS_OZONE_WL = "1";

  xdg.portal.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
