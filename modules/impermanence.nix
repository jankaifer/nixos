{ config, lib, ... }:

{
  options.custom.impermanence =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to erase root on boot.
        '';
      };
    };

  config = lib.mkIf config.custom.impermanence.enable
    {
      environment.persistence."/persist" = {
        hideMounts = true;
        directories = [
          "/etc/NetworkManager/system-connections"
          "/etc/mullvad-vpn"
          # I need to persist ssh keys, this persists a bit more,
          # but I have no idea how to persist just the keys without having to create them manually
          "/etc/ssh"
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

        users."${config.custom.options.username}" = {
          directories = [
            ".cache"
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
            "VirtualBox VMs"
            "dev"
            "exercism"
          ];

          files = [
            ".config/monitors.xml"
          ];
        };
      };

      programs.fuse.userAllowOther = true;

      home-manager.users."${config.custom.options.username}" = {
        imports = [ ./impermanence/home-manager.nix ];

        # Files that we want to track in git
        home.persistence."/etc/nixos/dotfiles/" = {
          removePrefixDirectory = true;
          allowOther = true;
          directories = [ ];
          files = [
            "hyper/.config/hyper/.hyper.js"
            "vscode/.config/Code/User/settings.json"
            "vscode/.config/Code/User/keybindings.json"
          ];
        };
      };
    };
}
