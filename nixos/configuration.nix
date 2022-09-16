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

  # console = {
  #   font = "ter-i32b";
  #   useXkbConfig = true;
  #   earlySetup = true;
  #   packages = with pkgs; [ terminus_font ];
  # };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.desktopManager.xterm.enable = true;
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


  # nixpkgs.overlays = [
  #   (self: super: {
  #     steam = super.steam.override {
  #       extraPkgs = pkgs: [ self.xlibs.libX11
  #                           self.xorg_sys_opengl
  #                           self.gcc-unwrapped.lib
  #                           self.gap-minimal
  #                           self.utillinux ];
  #     };
  #   })
  # ];

  # users.defaultUserShell = pkgs.zsh;

  # programs = {
  #   vim.defaultEditor = true;
  #   adb.enable = true;

  #   zsh = {
  #     enable = true;
  #     promptInit = ''
  #       eval "$(direnv hook zsh)"
  #       source ${../configs/p10k.zsh}
  #       source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
  #     '';
  #     enableBashCompletion = true;
  #     shellAliases =
  #       let
  #         zsh = "${pkgs.zsh}/bin/zsh";
  #       in
  #       {
  #         rebuild = "sudo nixos-rebuild switch |& nom";
  #         logout = "sudo systemctl restart display-manager";
  #         nsu = "nsu-run bash";
  #       };

  #     ohMyZsh.enable = true;
  #     ohMyZsh.plugins = [
  #       "vi-mode"
  #       "extract"
  #       "wd"
  #     ];
  #   };
  # };

  # # Fixes for steam from https://github.com/NixOS/nixpkgs/blob/nixos-20.09/nixos/modules/programs/steam.nix
  # hardware.opengl = { # this fixes the "glXChooseVisual failed" bug, context: https://github.com/NixOS/nixpkgs/issues/47932
  #   enable = true;
  #   driSupport32Bit = true;
  # };

  # hardware.steam-hardware.enable = true;

  # virtualisation = {
  #   docker = {
  #     enable = true;
  #     enableOnBoot = true;
  #   };
  #   lxd.enable = true;
  #   lxd.recommendedSysctlSettings = true;
  #   lxd.package = unstable.lxd; # There seems to be issue with sharing Xserver in version 4.5
  #   lxc.lxcfs.enable = true;
  # };

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

  fonts.fonts = with pkgs; [
    fira-code
    fira-code-symbols
    nerdfonts
    siji
  ];

  programs.light.enable = true;
}
