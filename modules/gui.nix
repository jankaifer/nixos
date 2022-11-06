{ config, lib, pkgs, ... }:

let
  unstable = import ./nixpkgs-unstable { config = { allowUnfree = true; }; };
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
    };

  config = lib.mkIf config.custom.gui.enable
    {
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

      programs = {
        # To allow configuration of gnome
        dconf.enable = true;

        # More info on wiki: https://nixos.wiki/wiki/Steam
        steam.enable = true;
      };

      environment.systemPackages = with pkgs;
        [
          firefox
          google-chrome
          brave
          zoom-us
          vlc
          gparted
          playerctl
          xournalpp
          gnome.seahorse
          gnome.dconf-editor
          gnome.gnome-software
          gnome.gnome-tweaks

          # Electron evil apps
          atom
          signal-desktop
          bitwarden
          gitkraken
          spotify
          unstable.pkgs.discord
          slack
          etcher
        ];

      ## Force Chromium based apps to render using wayland
      ## It is sadly not ready yet - electron apps will start missing navbars and they are still blurry 
      # environment.sessionVariables.NIXOS_OZONE_WL = "1";

      xdg.portal.enable = true;
    };
}
