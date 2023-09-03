{ config, lib, pkgs, ... }:

let
  stablePkgs = import
    (fetchTarball {
      url = https://github.com/NixOS/nixpkgs/archive/60c0f762658916a4a5b5a36b3e06486f8301daf4.tar.gz;
      sha256 = "0z6jy05yawj2pkinpyjlpym5niij2scxn6cd2w1p9wrfxw0hw8ra";
    })
    { };
in
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

      idleDelay = lib.mkOption {
        default = 300;
        example = 60;
        description = ''
          How many seconds of inactivity will power-off screen. 0 is infinity
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

      services.logind.extraConfig = ''
        HandleLidSwitch=suspend                # suspend when on battery
        HandleLidSwitchExternalPower=lock      # lock on AC 
        HandleLidSwitchDocked=lock             # lock on external monitor
      '';

      # Touchpad configs
      services.xserver.libinput = {
        enable = true;
        touchpad.naturalScrolling = true;
        touchpad.additionalOptions = ''MatchIsTouchpad "on"'';
      };

      services.flatpak.enable = true;

      nixpkgs.config.permittedInsecurePackages = [
        "electron-12.2.3" # Needed for etcher: https://github.com/NixOS/nixpkgs/issues/153537
        "openssl-1.1.1t" # Needed for the newest gnome
        "openssl-1.1.1u" # Don't know why
      ];

      # Virtualbox
      # virtualisation.virtualbox.host.enable = true;
      # users.extraGroups.vboxusers.members = [ "pearman" ];

      # Use custom user profile pic
      boot.postBootCommands =
        let
          gdm_user_conf = ''
            [User]
            Session=
            XSession=
            Icon=${../profile-pics/profile-pic.png}
            SystemAccount=false
          '';
        in
        ''
          echo '${gdm_user_conf}' > /var/lib/AccountsService/users/perman
        '';

      home-manager.users.pearman = { lib, ... }: {
        dconf.settings = let gvariant = lib.hm.gvariant; in {
          # Allow fractional scaling in wayland - produces blurry image
          # "org/gnome/mutter" = {
          #   experimental-features = [ "scale-monitor-framebuffer" ];
          # };

          # Used keyboad layout
          "org/gnome/desktop/input-sources".sources = [
            (gvariant.mkTuple [ "xkb" "fck" ])
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

          # Power preferences
          "org/gnome/shell"."last-selected-power-profile" = "power-saver";
          "org/gnome/settings-daemon/plugins/power" = {
            "sleep-inactive-battery-timeout" = 3600;
            "sleep-inactive-ac-type" = "nothing";
            "power-button-action" = "nothing";
            "show-battery-percentage" = true;
          };
          "org/gnome/desktop/interface"."show-battery-percentage" = true;
          "org/gnome/desktop/session"."idle-delay" = gvariant.mkUint32 config.custom.gui.idleDelay;

          # Night light
          "org/gnome/settings-daemon/plugins/color" = {
            "night-light-enabled" = true;
            "night-light-temperature" = gvariant.mkUint32 2700;
          };

          # Analytics
          "org/gnome/desktop/privacy"."report-technical-problems" = true;

          # Workspaces
          "org/gnome/mutter" = {
            "dynamic-workspaces" = false;
            "workspaces-only-on-primary" = true;
            "edge-tiling" = true;
          };
          # "org/gnome/desktop/wm/preferences"."num-workspaces" = 8;

          # Shortcuts
          "org/gnome/desktop/wm/keybindings" = {
            "switch-to-workspace-left" = [ "<Control><Super>n" "<Control><Super>Left" ];
            "switch-to-workspace-right" = [ "<Control><Super>o" "<Control><Super>Right" ];
            "move-to-workspace-left" = [ "<Shift><Control><Super>n" "<Shift><Control><Super>Left" ];
            "move-to-workspace-right" = [ "<Shift><Control><Super>o" "<Shift><Control><Super>Right" ];
            "maximize" = [ "<Shift><Super>i" "<Shift><Super>Up" ];
            "unmaximize" = [ "<Shift><Super>e" "<Shift><Super>Down" ];
          };
          "org/gnome/mutter/keybindings" = {
            "toggle-tiled-left" = [ "<Shift><Super>n" "<Shift><Super>Left" ];
            "toggle-tiled-right" = [ "<Shift><Super>o" "<Shift><Super>Right" ];
          };
          "org/gnome/settings-daemon/plugins/media-keys"."screensaver" = [ "<Super>u" ];

          # Extensions
          # schema for that extension: https://github.com/pop-os/shell/blob/30bf682bf85a59f19e41621530df0a914e89f1f2/schemas/org.gnome.shell.extensions.pop-shell.gschema.xml
          "org/gnome/shell"."enabled-extensions" = [ "pop-shell@system76.com" ];
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
          gnomeExtensions.pop-shell
          google-chrome
          gparted
          krita
          libsForQt5.filelight
          playerctl
          vlc
          xournalpp
          audacity

          # Zoom is broken on Linux, the browser version works better
          # zoom-us

          # Hyper is broken on latest unstable: https://github.com/NixOS/nixpkgs/issues/105961
          stablePkgs.hyper
          # Hyper is broken on latest unstable: https://github.com/NixOS/nixpkgs/issues/105961
          stablePkgs.insomnia

          # Electron evil apps
          atom
          bitwarden
          etcher
          gitkraken
          signal-desktop
          slack
          spotify
          discord

          lutris
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














