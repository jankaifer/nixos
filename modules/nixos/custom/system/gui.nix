{ config, lib, pkgs, ... }:

let
  cfg = config.custom.system.gui;
in
{
  options.custom.system.gui = {
    enable = lib.mkEnableOption "gui";
  };

  config = lib.mkIf cfg.enable {
    # Networking
    networking.networkmanager.enable = true;

    # This option is shared between X11 and Wayland, just the name is confusing
    services.xserver = {
      enable = true;

      # Enable the GNOME Desktop Environment.
      desktopManager.gnome.enable = true;
      displayManager.gdm = {
        enable = true;
        wayland = true;
        settings = {
          greeter.IncludeAll = true;
        };
      };
    };

    services.logind.extraConfig = ''
      HandleLidSwitch=suspend                # suspend when on battery
      HandleLidSwitchExternalPower=lock      # lock on AC 
      HandleLidSwitchDocked=lock             # lock on external monitor
    '';

    # Touchpad configs
    services.libinput = {
      enable = true;
      touchpad.naturalScrolling = true;
      touchpad.additionalOptions = ''MatchIsTouchpad "on"'';
    };

    services.flatpak.enable = true;

    # Audio
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true;
    };
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    sound.enable = true;

    programs = {
      dconf.enable = true;
      gnome-terminal.enable = true;
      zsh.vteIntegration = true;
    };

    # Gnome stuff I don't want
    environment.gnome.excludePackages = [
      pkgs.gnome-console
      pkgs.gnome-connections
      pkgs.gnome.cheese # webcam tool
      pkgs.gnome.epiphany # web browser
      pkgs.gnome.geary # email reader
      pkgs.gnome.evince # document viewer
      pkgs.gnome.totem # video player
      pkgs.gnome.gnome-contacts
      pkgs.gnome.gnome-maps
      pkgs.gnome.gnome-music
      pkgs.gnome.gnome-weather
    ];

    environment.systemPackages = [
      pkgs.audacity
      pkgs.brave
      pkgs.firefox
      pkgs.gnome.dconf-editor
      pkgs.gnome.gnome-boxes
      pkgs.gnome.gnome-software
      pkgs.gnome.gnome-tweaks
      pkgs.gnome.seahorse
      pkgs.gnomeExtensions.pop-shell
      pkgs.google-chrome
      pkgs.gparted
      pkgs.krita
      pkgs.libsForQt5.filelight
      pkgs.pgadmin4-desktopmode
      pkgs.playerctl
      pkgs.prusa-slicer
      pkgs.virt-manager
      pkgs.vlc
      pkgs.xournalpp

      # Electron evil apps
      pkgs.bitwarden
      pkgs.signal-desktop
      pkgs.slack
      pkgs.spotify
      pkgs.discord

      pkgs.lutris

      pkgs.unstable.keymapp
    ];

    ## Force Chromium based apps to render using wayland
    ## VSCode tends to break often with this
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
