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

  config = lib.mkIf config.custom.common.enable
    (
      {
        nix.settings.experimental-features = [ "nix-command" "flakes" ];
        nix.settings.trusted-public-keys = [
          # This is the default key used by public nix cache
          # https://github.com/NixOS/nixpkgs/blob/1a3c95e3b23b3cdb26750621c08cc2f1560cb883/nixos/modules/config/nix.nix#L367C31-L367C95
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        ] ++ (import ./public-ssh-keys.nix);

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

        environment.shellAliases = lib.mkForce
          {
            pls = "sudo";
            n = "pnpm";
            y = "yarn";
            gpf = "git push --force-with-lease";
            gfa = "git fetch --all";
            gr = "git rebase";
            gm = "git merge";
            gps = "git push";
            gpl = "git pull";
          };

        # Allow unfree packages
        nixpkgs.config.allowUnfree = true;

        programs = {
          vim.defaultEditor = true;
        };
      }
    );
}
