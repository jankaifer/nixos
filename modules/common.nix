{ config, lib, pkgs, ... }@args:

let
  all-machine-configs = import ./all-machine-configs.nix;
  machine-names-with-ip = builtins.filter
    (machine-name: all-machine-configs."${machine-name}".static-ip != null)
    (builtins.attrNames all-machine-configs);
  generate-ssh-config = host: attrs:
    ''
      Host ${host}.local
        HostName ${attrs.static-ip}
        User ${attrs.username}
    '';
  ssh-configs = map
    (machine-name: generate-ssh-config machine-name all-machine-configs."${machine-name}")
    machine-names-with-ip;
  extra-ssh-config = builtins.concatStringsSep "\n" ssh-configs;
in
{
  options.custom.common = {
    enable = lib.mkOption {
      default = false;
      example = true;
      description = ''
        Common config
      '';
    };
  };

  config = lib.mkIf config.custom.common.enable ({
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nix.settings.trusted-users = [ config.custom.options.username ];

    networking.hostName = config.custom.options.hostName;

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

    networking.hosts =
      builtins.listToAttrs (map
        (machine-name: {
          name = all-machine-configs."${machine-name}".static-ip;
          value = [ "${machine-name}.local" ];
        })
        machine-names-with-ip
      );
    programs.ssh.extraConfig = extra-ssh-config;
  });
}
