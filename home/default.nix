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
        };
        extraConfig = builtins.readFile (toRelativePath "configs/i3.conf");
      };
  };

  programs.git = {
    enable = true;
    userName = "Jan Kaifer";
    userEmail = "jan@kaifer.cz";
  };

  programs.autorandr = {
    enable = true;
    profiles =
      let
        c9 = "00ffffffffffff0009e5210800000000011c0104b51f117803f170aa5445a9240f50540000000101010101010101010101010101010150d000a0f0703e803020350035ae1000001a00000000000000000000000000000000001a000000fe00424f452048460a202020202020000000fe004e5631343051554d2d4e35340a014a02030f00e3058000e60605016a6a24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a";
        thinkVision = "00ffffffffffff0030aeb0614656305a1a1d0104b53c22783e2215ac5135b6260e5054a10800d1c081c0810081809500a9c0b30001014dd000a0f0703e803020350055502100001aa36600a0f0701f803020350055502100001a000000fd0017501ea03c010a202020202020000000fc004c454e20503237752d31300a2001ed020320f14b010203121113041490051f230907078301000067030c0020003878565e00a0a0a029503020350055502100001ae26800a0a0402e603020360055502100001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000063";
        aoc = "00ffffffffffff0005e37727610300000c1b0103803c22782a2895a7554ea3260f5054bd4b00d1c081808140950f9500b30081c001014dd000a0f0703e803020350055502100001aa36600a0f0701f803020350055502100001a000000fc005532373737420a202020202020000000fd0017501ea03c000a20202020202001ba020333f14c9004031f1301125d5e5f606123090707830100006d030c001000387820006001020367d85dc401788003e30f000c011d007251d01e206e28550055502100001e8c0ad08a20e02d10103e96005550210000184d6c80a070703e8030203a0055502100001a04740030f2705a80b0588a0055502100001a0000000016";

        monitorConfig4k = {
          DP-2 = {
            enable = true;
            primary = true;
            scale = {
              x = .75;
              y = .75;
            };
            position = "0x0";
            mode = "3840x2160";
            rate = "60.00";
          };
          eDP-1 = {
            enable = true;
            primary = false;
            scale = {
              x = .5;
              y = .5;
            };
            position = "480x1620";
            mode = "3840x2160";
            rate = "60.00";
          };
        };
      in
      {
        "c9" = {
          fingerprint = {
            eDP-1 = c9;
          };
          config = {
            eDP-1 = {
              enable = true;
              primary = true;
              position = "0x0";
              scale = {
                x = .5;
                y = .5;
              };
              mode = "3840x2160";
              rate = "60.00";
            };
          };
        };
        "c9-thinkvision" = {
          fingerprint = {
            eDP-1 = c9;
            DP-2 = thinkVision;
          };
          config = monitorConfig4k;
        };
        "c9-aoc" = {
          fingerprint = {
            eDP-1 = c9;
            DP-2 = aoc;
          };
          config = monitorConfig4k;
        };
      };
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
          geometry = "0x5-14+50";
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
      reload-monitors
      eval $(/run/wrappers/bin/gnome-keyring-daemon --start --daemonize)
      export SSH_AUTH_SOCK
    '';
  };
}
