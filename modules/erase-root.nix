{ config, lib, pkgs, ... }:

{
  options.custom.erase-root =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to erase root on boot.
        '';
      };
    };

  config = lib.mkIf config.custom.erase-root.enable
    {
      environment.persistence."/persist" = {
        hideMounts = true;
        directories = [
          "/etc/NetworkManager/system-connections"
          "/var/lib/bluetooth"
          "/var/lib/docker"
          "/var/lib/flatpak"
          "/var/lib/fprint"
          "/var/lib/libvirt"
          "/var/lib/systemd/coredump"
        ];
        files = [
          "/etc/machine-id"
        ];

        users.pearman = {
          directories = [
            ".cache"
            ".config/Bitwarden"
            ".config/BraveSoftware"
            ".config/Code"
            ".config/Signal"
            ".config/Slack"
            ".config/discord"
            ".config/gh"
            ".config/spotify"
            ".config/turborepo"
            ".factorio"
            ".local/share/Steam"
            ".local/share/Teraria"
            ".local/share/direnv"
            ".local/share/flatpak"
            ".local/share/fnm"
            ".local/share/keyrings"
            ".ssh"
            "Documents"
            "Pictures"
            "dev"
            ".zoom"
          ];

          files = [
            ".zsh_history"
            ".bash_history"
            ".config/monitors.xml"
          ];
        };
      };

      programs.fuse.userAllowOther = true;

      home-manager.users.pearman = {
        imports = [ ./impermanence/home-manager.nix ];

        # Files that we want to track in git
        home.persistence."/etc/nixos/modules/dotfiles/" = {
          removePrefixDirectory = true;
          allowOther = true;
          directories = [ ];
          files = [
            "hyper/.config/hyper/.hyper.js"
          ];
        };
      };
    };
}
