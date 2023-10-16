{ config, lib, pkgs, ... }:

{
  options.custom.wifi-setup =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Include wifi configurations and passwords for my home wifi networks.
        '';
      };
    };

  config =
    lib.mkIf config.custom.fck.enable {
      networking.wireless.environmentFile = config.age.secrets.wifi-passwords.path;
      networking.wireless.networks = {
        DormWifi.psk = "@DORM_PASS@";
      };
    };
}


