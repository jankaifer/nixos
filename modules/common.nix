{ pkgs, ... }@args:

let
  secrets = import ../secrets { };
  unstable = import ./nixpkgs-unstable { config = { allowUnfree = true; }; };
in
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.useOSProber = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Audio
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

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

  # Setup TUI
  console = {
    font = "ter-i32b";
    useXkbConfig = true;
    earlySetup = true;
    packages = with pkgs; [ terminus_font ];
  };

  # Enable the windowing system (the name is wrong - it can be wayland).
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Modify GNOME default settings: https://discourse.nixos.org/t/gnome3-settings-via-configuration-nix/5121
  # Source for these modifications: https://guides.frame.work/Guide/Fedora+36+Installation+on+the+Framework+Laptop/108#s655
  # services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
  #   [org.gnome.mutter]
  #   experimental-features=[]
  # '';

  # Touchpad configs
  services.xserver.libinput = {
    enable = true;
    touchpad.naturalScrolling = true;
    touchpad.additionalOptions = ''MatchIsTouchpad "on"'';
  };

  # Configure keymap
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
  nixpkgs.config.permittedInsecurePackages = [
    "electron-12.2.3" # Needed for etcher: https://github.com/NixOS/nixpkgs/issues/153537
  ];

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

  environment.systemPackages = with pkgs;
    [
      # Basic utils
      wget
      iw
      tree
      lshw
      git
      gnumake
      gcc
      htop
      zsh-you-should-use
      acpi
      parted
      direnv
      cryptsetup
      binutils
      killall
      libnotify
      unzip
      bitwarden-cli
      wally-cli
      niv

      # X server
      xorg.xeyes
      xorg.xhost

      # Nix
      nixpkgs-fmt
      nix-output-monitor

      # Python
      python38Full
      black

      # Node
      nodejs
      nodePackages.yarn
      nodePackages.npm

      # Docker
      docker

      # Rust
      rustc
      cargo

      # Prolog
      swiProlog

      # GUI
      firefox
      google-chrome
      brave
      zoom-us
      vlc
      gparted
      playerctl
      xournalpp
      gnome.seahorse
      gnome.dconf-editor
      gnome.gnome-software
      gnome.gnome-tweaks

      # Electron evil apps
      atom
      signal-desktop
      bitwarden
      gitkraken
      spotify
      unstable.pkgs.discord
      slack
      etcher
    ];

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
