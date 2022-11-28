{ config, lib, pkgs, ... }@args:

let
  nixosRepoPath = "/persist/home/pearman/dev/jankaifer/nixos";
  unstable = import ./nixpkgs-unstable { config = { allowUnfree = true; }; };
in
{
  nix.nixPath =
    [
      "nixpkgs=${nixosRepoPath}/modules/nixpkgs"
      "nixos-config=${nixosRepoPath}/machines/${config.networking.hostName}/configuration.nix"
    ];

  # Setup user
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
      hashedPassword = lib.strings.fileContents ../passwordFile;
    };
  };

  boot.supportedFilesystems = [ "ntfs" ];

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

  # Inceare temporary storage size
  services.logind.extraConfig = "RuntimeDirectorySize=6G";

  # Make SUDO to remember fingerprint/password for 15 minutes
  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=15
  '';

  # Link /etc/nixos to this repo
  environment.etc.nixos = {
    enable = true;
    source = nixosRepoPath;
    target = "nixos";
  };

  environment.etc.vimrc = {
    enable = true;
    source = "${nixosRepoPath}/modules/dotfiles/vim/.vimrc";
    target = "vimrc";
  };

  environment.sessionVariables = rec {
    XDG_CACHE_HOME = "\${HOME}/.cache";
    XDG_CONFIG_HOME = "\${HOME}/.config";
    XDG_BIN_HOME = "\${HOME}/.local/bin";
    XDG_DATA_HOME = "\${HOME}/.local/share";

    EDITOR = "vim";

    PATH = [
      "\${XDG_BIN_HOME}"
    ];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Use ZSH
  users.defaultUserShell = pkgs.zsh;

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      enableBashCompletion = true;
      promptInit = ''
        eval "$(direnv hook zsh)"
        eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"
      '';
      shellAliases = {
        rebuild = "sudo ${nixosRepoPath}/scripts/rebuild.sh switch |& nom";
        new-next-repro = "${nixosRepoPath}/scripts/new-next-repro.sh";
        # node tools are pain to manage without steam-run
        sr = "steam-run";
        pnpm = "sr pnpm";
        yarn = "sr yarn";
        npm = "sr npm";
        npx = "sr npx";
        corepack = "sr corepack";
        node = "sr node";
      };
    };

    vim.defaultEditor = true;
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
      gh
      steam-run
      unstable.fnm

      # Nix
      nixpkgs-fmt
      nix-output-monitor

      # Python
      python38Full
      black

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
    users.pearman = {
      nixpkgs.config.allowUnfree = true;

      programs = {
        # home-manager.enable = true;

        git = {
          enable = true;
          userName = "Jan Kaifer";
          userEmail = "jan@kaifer.cz";
          extraConfig = {
            pull = {
              rebase = true;
            };
            gpg.format = "ssh";
            gpg.ssh.defaultKeyCommand = "ssh-add -L";
            commit.gpgsign = true;
            tag.gpgsign = true;
            init.defaultBranch = "main";
          };
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

      # For some reason vscode can't read the config when provided by impermanence
      home.file = {
        ".vimrc".source = ./dotfiles/vim/.vimrc;
        ".node-version".text = "v18.12.1";
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
