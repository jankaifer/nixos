{ pkgs, ... }@args:

with builtins;
{
  home-manager.useUserPackages = true;
  home-manager.users.pearman = { lib, ... }: {
    nixpkgs.config = {
      allowUnfree = true;
    };

    dconf.settings = with lib.hm.gvariant; {
      # Allow fractional scaling in wayland - produces blurry image
      # "org/gnome/mutter" = {
      #   experimental-features = [ "scale-monitor-framebuffer" ];
      # };

      # Used keyboad layout
      # "/org/gnome/desktop/input-sources".sources = [
      #   (mkTuple [ "xkb" "fck" ])
      # ];

      # Dock
      # "/org/gnome/shell"."favorite-apps" = [
      #   "brave-browser.desktop"
      #   "code.desktop"
      #   "org.gnome.Console.desktop"
      #   "org.gnome.Settings.desktop"
      #   "org.gnome.Nautilus.desktop"
      #   "signal-desktop.desktop"
      #   "slack.desktop"
      #   "spotify.desktop"
      # ];
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

      vim.enable = true;

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
      "nixpkgs/config.nix".source = ./dotfiles/nixpkgs.nix;
    };

    home.file = {
      ".vimrc".source = ./dotfiles/.vimrc;
    };

    # We will manage keyboard in global settings
    home.keyboard = null;
  };
}
