{ config, lib, pkgs, ... }@args:

{
  options.custom.common =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Common config
        '';
      };
    };

  config = lib.mkIf config.custom.common.enable (
    let
      nixosRepoPath = "/persist/home/pearman/dev/jankaifer/nixos";
    in
    {
      nix.nixPath =
        [
          "nixpkgs=${nixosRepoPath}/modules/nixpkgs"
          "nixos-config=${nixosRepoPath}/machines/${config.networking.hostName}/configuration.nix"
        ];

      nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

      environment.shellAliases = lib.mkForce
        {
          pls = "sudo";
          rebuild = "pls ${nixosRepoPath}/scripts/rebuild.sh switch";
          freeze-vscode-extensions = "${nixosRepoPath}/scripts/freeze-vscode-extensions.sh";
          n = "pnpm";
          y = "yarn";
          gpf = "git push --force-with-lease";
          gfa = "git fetch --all";
          gr = "git rebase";
          gm = "git merge";
          gps = "git push";
          gpl = "git pull";
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
        };

        vim.defaultEditor = true;

        nix-ld = {
          enable = true;
          libraries = with pkgs; [
            alsa-lib
            at-spi2-atk
            at-spi2-core
            atk
            cairo
            cups
            curl
            dbus
            expat
            fontconfig
            freetype
            fuse3
            gdk-pixbuf
            glib
            gtk3
            icu
            libGL
            libappindicator-gtk3
            libdrm
            libnotify
            libpulseaudio
            libuuid
            libxkbcommon
            mesa
            musl
            nspr
            nss
            openssl
            pango
            pipewire
            stdenv.cc.cc
            systemd
            xorg.libX11
            xorg.libXScrnSaver
            xorg.libXcomposite
            xorg.libXcursor
            xorg.libXdamage
            xorg.libXext
            xorg.libXfixes
            xorg.libXi
            xorg.libXrandr
            xorg.libXrender
            xorg.libXtst
            xorg.libxcb
            xorg.libxkbfile
            xorg.libxshmfence
            zlib
            zlib
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
        storageDriver = "btrfs";

      };

      environment.systemPackages = [
        # Docker
        pkgs.docker
        pkgs.docker-compose

        # Rust
        pkgs.rustup
      ];
    }
  );
}
