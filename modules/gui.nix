{ config, lib, pkgs, ... }:

{
  options.custom.gui =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to include GUI support on the system.
          This option should not be used on servers and live isos.
        '';
      };
    };

  config = lib.mkIf config.custom.gui.enable
    {
      # Networking
      networking.networkmanager.enable = true;

      # Enable the windowing system (the name is wrong - it can be wayland).
      services.xserver.enable = true;

      # Enable the GNOME Desktop Environment.
      services.xserver.displayManager.gdm.enable = true;
      services.xserver.displayManager.gdm.wayland = true;
      services.xserver.desktopManager.gnome.enable = true;

      # Modify GNOME default settings: https://discourse.nixos.org/t/gnome3-settings-via-configuration-nix/5121
      # Source for these modifications: https://guides.frame.work/Guide/Fedora+36+Installation+on+the+Framework+Laptop/108#s655
      # services.xserver.desktopManager.gnome.extraGSettingsOverrides = ''
      #   [org.gnome.mutter]
      #   experimental-features=[]
      # '';

      # Touchpad configs
      services.xserver.libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
        touchpad.additionalOptions = ''MatchIsTouchpad "on"'';
      };

      nixpkgs.config.permittedInsecurePackages = [
        "electron-12.2.3" # Needed for etcher: https://github.com/NixOS/nixpkgs/issues/153537
      ];

      home-manager.users.pearman = { lib, ... }: {
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
            "hyper.desktop"
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
          };

          # Do not show welcome tour on startup
          "org/gnome/shell"."welcome-dialog-last-shown-version" = "1000000";

          # Workspaces
          "org/gnome/mutter"."dynamic-workspaces" = false;
          "org/gnome/desktop/wm/preferences"."num-workspaces" = 8;

          # Shortcuts
          "/org/gnome/desktop/wm/keybindings" = {
            "switch-to-workspace-left" = [ "<Control>Left" ];
            "switch-to-workspace-right" = [ "<Control>Right" ];
            "move-to-workspace-left" = [ "<Shift><Control>Left" ];
            "move-to-workspace-right" = [ "<Shift><Control>Right" ];
          };
        };

        xresources.properties = {
          "Xcursor.size" = 64;
        };
      };

      programs = {
        # To allow configuration of gnome
        dconf.enable = true;
      };

      environment.systemPackages = with pkgs;
        [
          brave
          firefox
          gnome.dconf-editor
          gnome.gnome-software
          gnome.gnome-tweaks
          gnome.gnome-boxes
          gnome.seahorse
          google-chrome
          gparted
          krita
          libsForQt5.filelight
          playerctl
          vlc
          xournalpp
          zoom-us
          hyper

          # Electron evil apps
          atom
          bitwarden
          etcher
          gitkraken
          signal-desktop
          slack
          spotify
          discord
        ];

      ## Force Chromium based apps to render using wayland
      ## It is sadly not ready yet - electron apps will start missing navbars and they are still blurry 
      # environment.sessionVariables.NIXOS_OZONE_WL = "1";

      xdg.portal.enable = true;

      xdg.mime.defaultApplications =
        {
          "text/html" = "brave-browser.desktop";
          "x-scheme-handler/http" = "brave-browser.desktop";
          "x-scheme-handler/https" = "brave-browser.desktop";
          "x-scheme-handler/about" = "brave-browser.desktop";
          "x-scheme-handler/unknown" = "brave-browser.desktop";
        };
    };
}
