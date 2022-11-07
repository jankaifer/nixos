{ config, lib, pkgs, ... }@args:

let
  secrets = import ../secrets { };
in
{
  nix.nixPath = [
    "nixpkgs=/etc/nixos/modules/nixpkgs"
    "nixos-config=/etc/nixos/machines/${config.networking.hostName}/configuration.nix"
  ];

  # Setup user
  users = {
    mutableUsers = false;
    users.pearman = {
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
  };

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
    packages = with pkgs; [ terminus_font ];
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Make SUDO to remember fingerprint/password for 15 minutes
  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=15
  '';

  # Link /etc/nixos to this repo
  environment.etc.nixos = {
    enable = true;
    source = "/home/pearman/Projects/nixos";
    target = "nixos";
  };

  environment.etc.vimrc = {
    enable = true;
    source = "/etc/nixos/modules/dotfiles/vim/.vimrc";
    target = "vimrc";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Use ZSH
  users.defaultUserShell = pkgs.zsh;

  programs = {
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
          rebuild = "sudo /etc/nixos/scripts/rebuild.sh switch |& nom";
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
    ];

  home-manager = {
    useUserPackages = true;
    users.pearman = { lib, ... }: {
      nixpkgs.config.allowUnfree = true;

      dconf.settings = with lib.hm.gvariant; {
        # Allow fractional scaling in wayland - produces blurry image
        # "org/gnome/mutter" = {
        #   experimental-features = [ "scale-monitor-framebuffer" ];
        # };

        # Used keyboad layout
        "org/gnome/desktop/input-sources".sources = [
          (mkTuple [ "xkb" "fck" ])
        ];

        # Dock
        "org/gnome/shell"."favorite-apps" = [
          "brave-browser.desktop"
          "code.desktop"
          "org.gnome.Console.desktop"
          "org.gnome.Settings.desktop"
          "org.gnome.Nautilus.desktop"
          "signal-desktop.desktop"
          "slack.desktop"
          "spotify.desktop"
        ];

        # Over-amplification
        "org/gnome/desktop/sound"."allow-volume-above-100-percent" = true;

        # Increase font size (Works well with 100% QHD 13' laptop annd 4k 27' monitor)
        "org/gnome/desktop/interface"."text-scaling-factor" = 1.5;

        # Wallpaper
        "org/gnome/desktop/background" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri = "file://" + ../wallpapers/nix-wallpaper-simple-dark-gray.png;
        };

        # Do not show welcome tour on startup
        "org/gnome/shell"."welcome-dialog-last-shown-version" = "1000000";
      };

      xresources.properties = {
        "Xcursor.size" = 64;
      };

      programs = {
        # home-manager.enable = true;

        git = {
          enable = true;
          userName = "Jan Kaifer";
          userEmail = "jan@kaifer.cz";
        };

        vim = {
          enable = true;
          extraConfig = builtins.readFile ./dotfiles/vim/.vimrc;
        };

        zsh = {
          enable = true;
          enableCompletion = true;
          plugins = [
            {
              name = "zsh-nix-shell";
              file = "nix-shell.plugin.zsh";
              src = pkgs.fetchFromGitHub {
                owner = "chisui";
                repo = "zsh-nix-shell";
                rev = "v0.1.0";
                sha256 = "0snhch9hfy83d4amkyxx33izvkhbwmindy0zjjk28hih1a9l2jmx";
              };
            }
          ];
          prezto = {
            enable = true;
            prompt.theme = "steeef";
          };
        };
      };

      xdg.configFile = {
        "nixpkgs/config.nix".source = ./dotfiles/nix/nixpkgs.nix;
      };
    };
  };
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
