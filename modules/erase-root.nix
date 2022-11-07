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
          "/var/lib/systemd/coredump"
        ];
        files = [
          "/etc/machine-id"
        ];

        users.pearman = {
          directories = [
            "Documents"
            "Downloads"
            "Pictures"
            "Projects"

            ".ssh"

            ".cache"
            ".config/Bitwarden"
            ".config/BraveSoftware"
            ".config/Signal"
            ".config/Slack"
            ".config/spotify"
            ".local/share/Steam"
            ".local/share/direnv"
            ".local/share/flatpak"
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

        # Files that we want to trach in git
        home.persistence."/etc/nixos/modules/dotfiles/" = {
          removePrefixDirectory = true;
          allowOther = true;
          directories = [
          ];

          files = [
            "vim/.vimrc"
            "vscode/.config/Code/User/settings.json"
          ];
        };
      };
    };
}
