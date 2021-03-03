# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

with builtins;
let
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };

  toRelativePath = relativePath: toPath (./. + "/${relativePath}");
  moduleArgs = {
    inherit pkgs toRelativePath unstable;
  };

  makeScript = name: pkgs.writeScriptBin name (builtins.readFile (toRelativePath "scripts/${name}.sh"));
in
{
  imports =
    let
      home-manager = fetchGit {
        url = "https://github.com/nix-community/home-manager.git";
        ref = "release-20.09";
      };
    in
    [
      ./hardware-configuration.nix
      (import "${home-manager}/nixos")
    ];

  # fix errors in hardware-configuration.nix
  boot.kernelModules = [ "iwlwifi" "dm_crypt" ];
  boot.kernelPackages = pkgs.linuxPackages_5_10;
  boot.blacklistedKernelModules = [ "snd_hda_intel" "snd_soc_skl" ];
  # fileSystems."/" = {
  #   device = "/dev/VolGroup00/lvolnixos";
  #   fsType = "ext4";
  # };
  # swapDevices = [
  #   { device = "/dev/VolGroup00/swap; }
  # ];


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.useOSProber = true;

  networking.hostName = "c9"; # Define your hostname.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.wlp0s20f3.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "ter-i32b";
    useXkbConfig = true;
    earlySetup = true;
    packages = with pkgs; [ terminus_font ];
  };

  services = {
    xserver = {
      enable = true;
      displayManager.lightdm.enable = true;
      desktopManager.xterm.enable = true;
      libinput = {
        enable = true;
        naturalScrolling = true;
        additionalOptions = ''MatchIsTouchpad "on"'';
      };

      layout = "fck";
      extraLayouts.fck = {
        description = "Fancy czech keyboard";
        languages = [ "eng" "cs" ];
        symbolsFile = builtins.fetchurl {
          url = "https://gitlab.com/JanKaifer/fck/-/raw/master/cz";
        };
      };
    };

    actkbd = {
      enable = true;
      bindings = [
        { keys = [ 224 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -T .8"; }
        { keys = [ 225 ]; events = [ "key" ]; command = "/run/current-system/sw/bin/light -T 1.25"; }
      ];
    };

    blueman.enable = true;
    printing.enable = true;
    gnome3.gnome-keyring.enable = true;
    openssh.enable = true;
    autorandr.enable = true;
    autorandr.defaultTarget = "c9";
  };

  # Enable sound.
  sound.enable = true;
  hardware = {
    enableRedistributableFirmware = true;

    bluetooth.enable = true;
    pulseaudio.enable = true;
    pulseaudio.extraConfig = ''
      load-module module-alsa-sink   device=hw:0,0 channels=4
      load-module module-alsa-source device=hw:0,6 channels=4
    '';
  };

  security.pam = {
    services.lightdm.enableGnomeKeyring = true;

    # mount.enable = true;
    # mount.extraVolumes = [
    #   ''
    #     <volume path="/dev/VolGroup00/secure" mountpoint="/home/pearman/secure"/>
    #   ''
    # ];
  };

  users.users.pearman = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "adbusers"
    ];
  };

  nixpkgs.config.allowUnfree = true;

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
        # sha256 = "...";
      };

      # meta = {
      #  homepage = "https://github.com/dlenski/vpn-slice";
      #  description = "vpnc-script replacement for easy and secure split-tunnel VPN setup";
      #  license = stdenv.lib.licenses.gpl3Plus;
      #  maintainers = with maintainers; [ dlenski ];
      #};
    };
    pythonWithMyPackages = pythonFull.withPackages (pythonPackages: with pythonPackages; [
      pisek
    ]);
  in
  [
    wget
    iw
    tree
    lshw
    git
    pythonFull
    gnumake
    gcc
    black
    nixpkgs-fmt
    home-manager
    vim
    htop
    pythonPackages.ipython
    acpi
    parted
    zsh-powerlevel10k
    zsh-you-should-use
    direnv
    nodejs
    nodePackages.yarn
    nodePackages.npm
    cryptsetup
    binutils
    killall
    libnotify

    # Unstable
    unstable.nix-output-monitor

    # My scripts
    (makeScript "lock")
    (makeScript "reload-polybar")
    (makeScript "reload-monitors")
  ];

  users.defaultUserShell = pkgs.zsh;

  programs = {
    vim.defaultEditor = true;
    adb.enable = true;

    zsh = {
      enable = true;
      promptInit = ''
        eval "$(direnv hook zsh)"
        source ${./configs/p10k.zsh}
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      '';
      enableBashCompletion = true;
      shellAliases =
        let
          zsh = "${pkgs.zsh}/bin/zsh";
        in
        {
          rebuild = "sudo nixos-rebuild switch |& nom";
          logout = "sudo systemctl restart display-manager";
        };

      ohMyZsh.enable = true;
      ohMyZsh.plugins = [
        "vi-mode"
        "extract"
        "wd"
      ];
    };
  };

  environment.variables = {
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_CACHE_HOME = "$HOME/.cache";

    ANDROID_HOME = "$HOME/Android/Sdk"; # Set the home of the android SDK

    TERMINAL = "kitty";
    BROWSER = "google-chrome-stable";
  };


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?

  fonts.fonts = with pkgs; [
    fira-code
    fira-code-symbols
    nerdfonts
    siji
  ];

  programs.light.enable = true;

  home-manager.users.pearman = import ./home moduleArgs;
}
