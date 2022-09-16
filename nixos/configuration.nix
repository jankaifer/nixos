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
  secrets = import ../../nixos-secrets moduleArgs;

  moduleArgs = {
    inherit pkgs toRelativePath unstable secrets;
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
      ../hardware

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
    experimental-features=['scale-monitor-framebuffer']
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
      languages = [ "eng" "cs" ];
      symbolsFile = builtins.fetchurl {
        url = "https://gitlab.com/JanKaifer/fck/-/raw/master/cz";
      };
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

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
    vim.defaultEditor = true;

    # To allow configuration of gnome
    dconf.enable = true;

    zsh = {
      enable = true;
      promptInit = ''
        eval "$(direnv hook zsh)"
        source ${../configs/p10k.zsh}
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      '';
      enableBashCompletion = true;
      shellAliases =
        let
          zsh = "${pkgs.zsh}/bin/zsh";
        in
        {
          rebuild = "sudo nixos-rebuild switch |& nom";
        };

      ohMyZsh.enable = true;
      ohMyZsh.plugins = [
        "vi-mode"
        "extract"
        "wd"
      ];
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

  environment.variables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";
  };

  xdg.portal.enable = true;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
