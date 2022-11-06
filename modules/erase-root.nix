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

            { directory = ".ssh"; mode = "0700"; }

            ".cache"
            ".config/Bitwarden"
            ".config/Slack"
            ".config/BraveSoftware"
            ".config/Signal"
            ".config/spotify"
            ".local/share/Steam"
            ".local/share/direnv"
            ".local/share/flatpak"
          ];
        };
      };
    };
}
