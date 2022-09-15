# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

with builtins;
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };

  home-manager = fetchGit {
    url = "https://github.com/nix-community/home-manager.git";
    ref = "release-22.05";
  };

  toRelativePath = relativePath: toPath (./. + "/${relativePath}");
  moduleArgs = {
    inherit pkgs toRelativePath unstable;
  };

  # secrets = import ./nixos-secrets moduleArgs;
  # moduleArgs.secrets = secrets;
  # makeExecutable = name: path: pkgs.writeScriptBin name (builtins.readFile (toRelativePath path));
  # makeScript = name: makeExecutable name "scripts/${name}.sh";
in
{
  imports =
    [
      ./hardware/framework.nix
      (import "${home-manager}/nixos")
    ];

  # Update kernel
  boot.kernelPackages = pkgs.linuxPackages_5_18;

  # Use the systemd-boot EFI boot loader.
  boot.loader.grub.useOSProber = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";

  # Setup keyfile
  boot.initrd.secrets = {
    "/crypto_keyfile.bin" = null;
  };

  # Enable swap on luks
  boot.initrd.luks.devices."luks-03537895-0d55-4d42-83b0-28f2c82e6273".device = "/dev/disk/by-uuid/03537895-0d55-4d42-83b0-28f2c82e6273";
  boot.initrd.luks.devices."luks-03537895-0d55-4d42-83b0-28f2c82e6273".keyFile = "/crypto_keyfile.bin";

  # Networking
  networking.hostName = "pearframe";
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

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable fingerprint
  services.fprintd.enable = true;

  # services.flatpak.enable = true;
  # services.openvpn.servers = secrets.openvpn;
  # services.blueman.enable = true;
  # services.printing.enable = true;
  # services.gnome3.gnome-keyring.enable = true;
  # services.openssh.enable = true;
  # services.autorandr.enable = true;
  # services.autorandr.defaultTarget = "c9";

  # hardware = {
  #   enableRedistributableFirmware = true;

  #   bluetooth.enable = true;
  # };
  # users.mutableUsers = false;
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
   #  hashedPassword = ;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; let
    pythonVersion = "38";
    pythonFull = pkgs."python${pythonVersion}Full";
    pythonPackages = pkgs."python${pythonVersion}Packages";
    pisek = pkgs."python${pythonVersion}Packages".buildPythonPackage rec {
      name = "pisek";
      version = "0.1";

      src = pkgs.fetchFromGitHub {
        owner = "kasiopea-org";
        repo = "${name}";
        rev = "${version}";
      };
    };
    pythonWithMyPackages = pythonFull.withPackages (pythonPackages: with pythonPackages; [
      pisek
    ]);
  in
  [
    # Basic utils
    wget
    iw
    tree
    lshw
    git
    gnumake
    gcc
    vim
    htop
    zsh-powerlevel10k
    zsh-you-should-use
    acpi
    parted
    direnv
    cryptsetup
    binutils
    killall
    libnotify
    gnome3.gnome-software

    # steam
    steam-run-native
    steam-run
    unstable.steam

    # X server
    xorg.xeyes
    xorg.xhost

    # Nix
    nixpkgs-fmt
    home-manager

    # Python
    pythonFull
    black
    pythonPackages.ipython

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

    # Unstable
    unstable.nix-output-monitor

    # My scripts
    # (makeScript "lock")
    # (makeScript "reload-polybar")
    # (makeScript "reload-monitors")
    # (makeScript "run-steam-game")
    # (makeExecutable "nsu-start" "NSU/nsu-start.sh")
    # (makeExecutable "nsu-stop" "NSU/nsu-stop.sh")
    # (makeExecutable "nsu-run" "NSU/nsu-run.sh")
    # (makeExecutable "nsu-save" "NSU/nsu-save.sh")
  ];

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
  #       source ${./configs/p10k.zsh}
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

  home-manager.users.pearman = import ./home moduleArgs;
}
