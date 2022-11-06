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
          "/var/lib/bluetooth"
          "/var/lib/systemd/coredump"
          "/etc/NetworkManager/system-connections"
          "/var/lib/fprint"
        ];
        files = [
          "/etc/machine-id"
        ];
      };
    };
}
