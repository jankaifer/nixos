{ config, lib, pkgs, ... }:

let
  cfg = config.custom.gnome;
  profileUUID = "9e6bced8-89d4-4c52-aead-bbd59cbaad09";
  inherit (config.custom) colors;
in
{
  imports = [ ./terminal.nix ];

  options.custom.gnome = {
    enable = lib.mkEnableOption "gnome";
    wallpaper = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nierWallpaper;
    };
    idleDelay = lib.mkOption {
      default = 300;
      example = 60;
      description = ''
        How many seconds of inactivity will power-off screen. 0 is infinity
      '';
    };
    font = {
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nerdfonts.override { fonts = [ "Hack" ]; };
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "Hack Nerd Font";
      };
      size = lib.mkOption {
        type = lib.types.int;
        default = 14;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    fonts.fontconfig.enable = true;
    home.packages = [ cfg.font.package ];
    xresources.properties."Xcursor.size" = 64;
    dconf.settings = {
      # Allow fractional scaling in wayland - produces blurry image
      "org/gnome/mutter" = {
        experimental-features = [ "scale-monitor-framebuffer" ];
      };

      # Fonts
      "org/gnome/desktop/interface".monospace-font-name = cfg.font.name;

      # Dark theme
      "org/gnome/desktop/interface".color-scheme = "prefer-dark";
      "org/gnome/terminal/legacy".theme-variant = "dark";

      # Wallpaper
      "org/gnome/desktop/background" = {
        picture-uri = "file://${cfg.wallpaper}";
        picture-uri-dark = "file://${cfg.wallpaper}";
      };
      "org/gnome/desktop/screensaver" = {
        picture-uri = "file://${cfg.wallpaper}";
      };

      # Sounds
      "org/gnome/desktop/sound".event-sounds = false;

      # Used keyboad layout
      "org/gnome/desktop/input-sources".sources = [
        (lib.hm.gvariant.mkTuple [ "xkb" "fck" ])
      ];

      # Dock
      "org/gnome/shell"."favorite-apps" = [
        "brave-browser.desktop"
        "code.desktop"
        "org.gnome.Terminal.desktop"
        "org.gnome.Settings.desktop"
        "org.gnome.Nautilus.desktop"
        "signal-desktop.desktop"
        "slack.desktop"
        "spotify.desktop"
      ];

      # Gnome Terminal shortcuts
      "org/gnome/terminal/legacy" = {
        "keybindings/copy" = "<Primary>c";
        "keybindings/paste" = "<Primary>v";
      };

      # Over-amplification
      "org/gnome/desktop/sound".allow-volume-above-100-percent = true;

      # Increase font size (Works well with 100% QHD 13' laptop annd 4k 27' monitor)
      # Alternative is using fractional scaling 150%
      # Problem with font scaling is that chrome doesn't pick it up properly (sometimes)
      # "org/gnome/desktop/interface"."text-scaling-factor" = 1.5;

      # Wallpaper
      "org/gnome/desktop/background" = {
        color-shading-type = "solid";
        picture-options = "zoom";
      };

      # Do not show welcome tour on startup
      "org/gnome/shell".welcome-dialog-last-shown-version = "1000000";

      # Power preferences
      "org/gnome/shell"."last-selected-power-profile" = "power-saver";
      "org/gnome/settings-daemon/plugins/power" = {
        sleep-inactive-battery-timeout = 3600;
        sleep-inactive-ac-type = "nothing";
        power-button-action = "nothing";
        show-battery-percentage = true;
      };
      "org/gnome/desktop/interface".show-battery-percentage = true;
      "org/gnome/desktop/session".idle-delay = lib.hm.gvariant.mkUint32 cfg.idleDelay;

      # Night light
      "org/gnome/settings-daemon/plugins/color" = {
        night-light-enabled = true;
        night-light-temperature = lib.hm.gvariant.mkUint32 2700;
      };

      # Analytics
      "org/gnome/desktop/privacy".report-technical-problems = true;

      # Workspaces
      "org/gnome/mutter" = {
        dynamic-workspaces = false;
        workspaces-only-on-primary = true;
        edge-tiling = true;
      };
      # "org/gnome/desktop/wm/preferences".num-workspaces = 8;

      # Shortcuts
      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-left = [ "<Control><Super>n" "<Control><Super>Left" ];
        switch-to-workspace-right = [ "<Control><Super>o" "<Control><Super>Right" ];
        move-to-workspace-left = [ "<Shift><Control><Super>n" "<Shift><Control><Super>Left" ];
        move-to-workspace-right = [ "<Shift><Control><Super>o" "<Shift><Control><Super>Right" ];
        maximize = [ "<Shift><Super>i" "<Shift><Super>Up" ];
        unmaximize = [ "<Shift><Super>e" "<Shift><Super>Down" ];
      };
      "org/gnome/mutter/keybindings" = {
        toggle-tiled-left = [ "<Shift><Super>n" "<Shift><Super>Left" ];
        toggle-tiled-right = [ "<Shift><Super>o" "<Shift><Super>Right" ];
      };
      "org/gnome/settings-daemon/plugins/media-keys".screensaver = [ "<Super>u" ];

      # Extensions
      # schema for that extension: https://github.com/pop-os/shell/blob/30bf682bf85a59f19e41621530df0a914e89f1f2/schemas/org.gnome.shell.extensions.pop-shell.gschema.xml
      "org/gnome/shell".enabled-extensions = [ "pop-shell@system76.com" ];

      "org/gnome/terminal/legacy/profiles:" = {
        default = profileUUID;
        list = [ profileUUID ];
      };
      "org/gnome/terminal/legacy/profiles:/:${profileUUID}" = {
        visible-name = "Oceanic Next";
        audible-bell = false;
        font = "${cfg.font.name} ${builtins.toString cfg.font.size}";
        use-system-font = false;
        use-theme-colors = false;
        background-color = colors.primary.background;
        foreground-color = colors.primary.foreground;
        bold-color = colors.primary.foreground;
        bold-color-same-as-fg = true;
        inherit (colors) palette;
        use-transparent-background = true;
        background-transparency-percent = 10;
      };
    };
  };
}
