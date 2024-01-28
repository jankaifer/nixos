{ config, lib, ... }:

let
  cfg = config.custom.system.impermanence;
  user = config.custom.system.user;
  persistancePath = "/persist";
  listOption = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
in
{
  options.custom.system.impermanence = {
    enable = lib.mkEnableOption "impermanence";
    directories = listOption;
    files = listOption;
    userDirectories = listOption;
    userFiles = listOption;
    # TODO: add these properly
    # directories = persistancePathOptions.directories // emptyDefault;
    # files = persistancePathOptions.files // emptyDefault;
    # userDirectories = userOptions.directories // emptyDefault;
    # userFiles = userOptions.files // emptyDefault;
  };

  config = lib.mkIf cfg.enable
    {
      environment.persistence.${persistancePath} = {
        hideMounts = true;
        directories = cfg.directories ++ [
          "/.cache/nix/"
          "/etc/NetworkManager/system-connections"
          "/etc/ssh" # I need to persist ssh keys, this persists a bit more, persising only keys broke permissions
          "/var/cache/"
          "/var/lib/bluetooth"
          "/var/lib/cups"
          "/var/lib/docker" # TODO: do not persist docker on server
          "/var/lib/flatpak"
          "/var/lib/fprint"
          "/var/lib/grafana"
          "/var/lib/libvirt"
          "/var/lib/private/victoriametrics"
          "/var/lib/systemd/coredump"
          "/var/lib/traefik"
          "/var/lib/vmagent"
        ];
        files = cfg.files ++ [
          "/etc/machine-id"
          "/var/lib/NetworkManager/secret_key"
          "/var/lib/NetworkManager/seen-bssids"
          "/var/lib/NetworkManager/timestamps"
        ];

        users.${user} = {
          # TODO: Collocate these with the actual apps using them
          directories = cfg.userDirectories ++ [
            ".cache"
            ".cargo"
            ".config/Bitwarden"
            ".config/BraveSoftware"
            ".config/Code"
            ".config/Signal"
            ".config/Slack"
            ".config/StradewValley"
            ".config/discord"
            ".config/exercism"
            ".config/gh"
            ".config/google-chrome"
            ".config/paradox-launcher-v2"
            ".config/spotify"
            ".config/turborepo"
            ".config/unity3d" # Used by unity games like Overcoocked2
            ".factorio"
            ".local/share"
            ".rustup"
            ".ssh"
            ".zoom"
            "Documents"
            "Pictures"
            "dev"
            "exercism"
          ];

          files = cfg.userFiles ++ [
            # TODO: collocate into gnome
            ".config/monitors.xml"
          ];
        };
      };

      programs.fuse.userAllowOther = true;
    };
}
