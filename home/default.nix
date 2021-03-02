{ pkgs, toRelativePath }:

with builtins;
let
  moduleArgs = {
    inherit pkgs toRelativePath;
  };
  mypkgs = import (toRelativePath "mypkgs") moduleArgs;
in
{
  nixpkgs.config = {
    allowUnfree = true;
  };

  home = {
    keyboard.layout = "fck";

    packages = with pkgs; [
      mypkgs.real-vnc-viewer

      firefox
      google-chrome
      zoom-us
      vlc
      kitty
      gnome3.seahorse
      gparted
      maim
      xclip
      bitwarden-cli
      dmenu
      i3status
      xorg.xfd
      xorg.xkill
      pavucontrol
      zscroll
      playerctl
      betterlockscreen
      feh
      dunst
      kazam
      nnn

      # Electron evil apps
      atom
      signal-desktop
      bitwarden
      mattermost-desktop
      vscode
      gitkraken
      spotify
      discord
      slack
      etcher
    ];
  };

  xresources.properties = {
    # "Xft.dpi" = 276;
    "Xcursor.size" = 64;
  };

  xsession = {
    enable = true;
    windowManager.i3 =
      let
        mod = "Mod4";
      in
      {
        enable = true;
        package = pkgs.i3-gaps;
        config = {
          bars = [ ];
          colors = { };
          floating = {
            modifier = mod;
          };
          fonts = [
            "Fira Code Retina 16"
          ];
          gaps = {
            inner = 15;
            smartGaps = true;
          };
          keybindings = { };
          modes = { };
          startup = [
            {
              command = "reload-monitors";
              always = true;
            }
          ];
        };
        extraConfig = builtins.readFile (toRelativePath "configs/i3.conf");
      };
  };

  programs = {
    git = {
      enable = true;
      userName = "Jan Kaifer";
      userEmail = "jan@kaifer.cz";
    };

    autorandr = import ./autorandr.nix moduleArgs;
  };

  services = {
    polybar = import ./polybar.nix moduleArgs;

    picom = {
      enable = true;
    };

    dunst = {
      enable = true;
      settings = {
        global = {
          markup = "full";
          geometry = "1000x5-14+50";
          shrink = "yes";
          padding = 15;
          horizontal_padding = 30;
          progress_bar = true;
          transparency = 0;
          frame_width = 5;
          frame_color = "#666666";
          ignore_newline = "no";
          stack_duplicates = true;
          font = "Fira Code 16";
          format = "<b>%a</b>\\n%s\\n%b";
          aligment = "right";
        };

        urgency_low = {
          background = "#222222";
          foreground = "#ffffff";
          timeout = 10;
        };

        urgency_normal = {
          background = "#444444";
          foreground = "#ffffff";
          timeout = 10;
        };

        urgency_critical = {
          background = "#990000";
          foreground = "#ffffff";
          frame_color = "#ff0000";
          timeout = 0;
        };
      };
    };
  };

  xdg.configFile = {
    "kitty/kitty.conf".source = toRelativePath "configs/kitty.conf";
  };

  home.file = {
    ".vimrc".source = toRelativePath "configs/.vimrc";
    ".xprofile".text = ''
      eval $(/run/wrappers/bin/gnome-keyring-daemon --start --daemonize)
      export SSH_AUTH_SOCK
    '';
  };
}
