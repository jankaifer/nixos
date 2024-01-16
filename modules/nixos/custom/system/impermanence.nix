{ config, options, lib, ... }:

let
  cfg = config.custom.system.impermanence;
  user = config.custom.system.user;
  persistancePath = "/persist";
  listOption = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
  };
  # persistancePathOptions = options.environment.persistence.${persistancePath};
  # userOptions = persistancePath.users.${user};
  # emptyDefault = {
  #   "default" = [ ];
  # };
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
          # I need to persist ssh keys, this persists a bit more,
          # but I have no idea how to persist just the keys without having to create them manually
          "/etc/ssh"
          "/etc/NetworkManager/system-connections"
          "/var/lib/bluetooth"
          "/var/lib/docker"
          "/var/lib/flatpak"
          "/var/lib/fprint"
          "/var/lib/libvirt"
          "/var/lib/systemd/coredump"
        ];
        files = cfg.files ++ [
          "/etc/machine-id"
        ];

        users.${user} = {
          directories = cfg.userDirectories ++ [
            ".cache"
            # TODO: Collocate these with the actual apps using them
            ".cargo"
            ".rustup"
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
