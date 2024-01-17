{ inputs, outputs, config, lib, pkgs, ... }:

let
  cfg = config.custom.system;
in
{
  imports = [
    ./development.nix
    ./gui.nix
    ./impermanence.nix
    ./user.nix
  ];

  options.custom.system = {
    nixosRepoPath = lib.mkOption {
      type = lib.types.str;
      default = "/persist/home/${cfg.user}/dev/jankaifer/nixos";
      description = "Path the this nixos config repo, this will be symlinked to /etc/nixos";
    };
  };

  config = {
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    boot.tmp.useTmpfs = lib.mkDefault true;

    # Use the systemd-boot EFI boot loader.
    boot.loader = {
      grub.useOSProber = lib.mkDefault false;
      systemd-boot.enable = lib.mkDefault true;
      efi.canTouchEfiVariables = lib.mkDefault true;
    };

    time.timeZone = lib.mkDefault "Europe/Prague";
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    i18n.extraLocaleSettings = lib.mkDefault {
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

    # Set reasonable defaults when running in a VM
    virtualisation.vmVariant = {
      virtualisation = {
        memorySize = lib.mkDefault 4096;
        cores = lib.mkDefault 4;
      };
      services = {
        xserver.displayManager = {
          gdm.autoSuspend = false;
          autoLogin = {
            enable = true;
            inherit (config.custom.system) user;
          };
        };
        nix-serve.enable = lib.mkForce false;
        resolved.extraConfig = lib.mkForce "";
      };
      networking.wg-quick.interfaces = lib.mkForce { };
      virtualisation.docker.storageDriver = lib.mkForce "overlay2";

      # When running in VM there won't be my config repo present, so I need to copy over the relevant bits
      home-manager.users.${cfg.user} = {
        home.file.".nixosConfig" = {
          source = ../../../..;
          recursive = true;
        };
        custom.impermanence.nixosRepoPath = "/home/${cfg.user}/.nixosConfig";
      };
    };

    virtualisation.docker = {
      enable = true;
      enableOnBoot = true;
      storageDriver = lib.mkDefault "btrfs";
    };

    console = {
      font = lib.mkDefault "ter-i32b";
      packages = [ pkgs.terminus_font ];
      useXkbConfig = lib.mkDefault true;
      earlySetup = lib.mkDefault true;
    };

    # Enable CUPS to print documents.
    services.printing.enable = lib.mkDefault true;

    # Make sude timeout longer
    security.sudo.extraConfig = ''
      Defaults        timestamp_timeout=15
    '';

    services.xserver = {
      layout = lib.mkDefault "fck";
      extraLayouts.fck = {
        description = "fck";
        languages = [ "en" "cs" ];
        symbolsFile = "${inputs.fckKeyboardLayout}/fck";
      };
    };

    networking.firewall.enable = false;

    nixpkgs.overlays = builtins.attrValues outputs.overlays;
    nixpkgs.config.allowUnfree = true;
    nix = {
      package = pkgs.nix;
      # Makes sure that nix uses the same version for these flakes
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      # Delete old system generations
      gc = {
        automatic = lib.mkDefault true;
        options = lib.mkDefault "--delete-older-than 28d";
        dates = lib.mkDefault "weekly";
      };
      settings = {
        auto-optimise-store = lib.mkDefault true;
        experimental-features = [ "nix-command" "flakes" ];
        # TODO: setup my other machines as substituters to provide binary caches
        # substituters = map (x: substituters.${x}.url) cfg.nix.substituters;
        # trusted-public-keys = map (x: substituters.${x}.key) cfg.nix.substituters;
      };
    };

    services.openssh.settings = {
      PasswordAuthentication = lib.mkDefault false;
      PubkeyAuthentication = lib.mkDefault true;
      PermitRootLogin = lib.mkDefault "no";
    };

    # Support zsa keyboards
    hardware.keyboard.zsa.enable = true;

    environment = {
      systemPackages = [
        pkgs.agenix
        pkgs.git
        pkgs.dnsutils
        pkgs.pciutils
      ];
      shells = [ pkgs.zsh ];
      pathsToLink = [ "/share/zsh" ];

      sessionVariables = {
        XDG_CACHE_HOME = "\${HOME}/.cache";
        XDG_CONFIG_HOME = "\${HOME}/.config";
        XDG_BIN_HOME = "\${HOME}/.local/bin";
        XDG_DATA_HOME = "\${HOME}/.local/share";

        EDITOR = "vim";

        PATH = [
          "\${XDG_BIN_HOME}"
        ];
      };

      # Link /etc/nixos to this repo
      etc.nixos = {
        enable = true;
        source = cfg.nixosRepoPath;
        target = "nixos";
      };
    };

    # I want to use VSCode server and use node projects normally
    programs.nix-ld = {
      enable = true;
      libraries = [
        pkgs.alsa-lib
        pkgs.at-spi2-atk
        pkgs.at-spi2-core
        pkgs.atk
        pkgs.cairo
        pkgs.cups
        pkgs.curl
        pkgs.dbus
        pkgs.expat
        pkgs.fontconfig
        pkgs.freetype
        pkgs.fuse3
        pkgs.gdk-pixbuf
        pkgs.glib
        pkgs.gtk3
        pkgs.icu
        pkgs.libGL
        pkgs.libappindicator-gtk3
        pkgs.libdrm
        pkgs.libnotify
        pkgs.libpulseaudio
        pkgs.libuuid
        pkgs.libxkbcommon
        pkgs.mesa
        pkgs.musl
        pkgs.nspr
        pkgs.nss
        pkgs.openssl
        pkgs.pango
        pkgs.pipewire
        pkgs.stdenv.cc.cc
        pkgs.systemd
        pkgs.xorg.libX11
        pkgs.xorg.libXScrnSaver
        pkgs.xorg.libXcomposite
        pkgs.xorg.libXcursor
        pkgs.xorg.libXdamage
        pkgs.xorg.libXext
        pkgs.xorg.libXfixes
        pkgs.xorg.libXi
        pkgs.xorg.libXrandr
        pkgs.xorg.libXrender
        pkgs.xorg.libXtst
        pkgs.xorg.libxcb
        pkgs.xorg.libxkbfile
        pkgs.xorg.libxshmfence
        pkgs.zlib
      ];
    };
  };
}
