{ pkgs, toRelativePath, unstable, ... }@rest:

with builtins;
let
  moduleArgs = {
    inherit pkgs toRelativePath;
  } // rest;
  mypkgs = import (toRelativePath "mypkgs") moduleArgs;
in
{
  home-manager.useUserPackages = true;
  home-manager.users.pearman = { config, ... }: {
    nixpkgs.config = {
      allowUnfree = true;
    };

    # Allow fractional scaling in wayland
    dconf.settings = {
      "org/gnome/mutter" = {
        experimental-features = [ "scale-monitor-framebuffer" ];
      };
    };

    xresources.properties = {
      "Xcursor.size" = 64;
    };

    programs = {
      git = {
        enable = true;
        userName = "Jan Kaifer";
        userEmail = "jan@kaifer.cz";
      };

      vim = {
        enable = true;
        extraConfig = builtins.readFile (toRelativePath "configs/.vimrc");
      };

      vscode = {
        enable = true;
        package = pkgs.vscode.fhsWithPackages (
          ps: with ps; [
            # Rust
            rustup
            zlib
          ]
        );
        extensions = with pkgs.vscode-extensions; [
          dracula-theme.theme-dracula
          vscodevim.vim
          yzhang.markdown-all-in-one
        ];
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
      };
    };

    xdg.configFile = {
      "kitty/kitty.conf".source = toRelativePath "configs/kitty.conf";
      "nixpkgs/config.nix".source = toRelativePath "configs/nixpkgs.nix";
    };

    home = {
      # We will manage keyboard in global settings
      keyboard = null;

      file = {
        # Symlink my keyboard configs to a location used by GNOME
        ".config/xkb".source = config.lib.file.mkOutOfStoreSymlink (pkgs.xkeyboard_config.outPath + "/share/X11/xkb/");
      };

      packages = with pkgs; [
        (makeDesktopItem {
          name = "realvnc-viewer";
          desktopName = "Real VNC Viewer";
          exec = "${mypkgs.real-vnc-viewer}/bin/realvnc-viewer";
        })

        firefox
        google-chrome
        brave
        zoom-us
        vlc
        gnome3.seahorse
        gparted
        maim
        xclip
        bitwarden-cli
        xorg.xkill
        zscroll
        playerctl
        unzip
        xournalpp

        # Electron evil apps
        atom
        signal-desktop
        bitwarden
        gitkraken
        spotify
        discord
        slack
        # etcher
      ];
    };
  };
}
