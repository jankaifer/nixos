{ config, lib, pkgs, ... }:

{
  options.custom.framework =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to enable fixes for Framework.
        '';
      };
    };

  config = lib.mkIf config.custom.framework.enable
    {
      # Enable fingerprint
      services.fprintd.enable = true;

      boot.kernelParams = [
        # Fix brightness keys (https://dov.dev/blog/nixos-on-the-framework-12th-gen)
        "module_blacklist=hid_sensor_hub"
      ];

      services.thermald.enable = true;
    };
}
