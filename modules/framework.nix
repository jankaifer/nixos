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
        # In case your laptop hangs randomly (https://nixos.wiki/wiki/Bootloader)
        "intel_idle.max_cstate=1"
      ];

      # My framework started overheating - it has  needlessly high frequency
      # auto-cpufreq mitigates that a bit - it makes fan noise bearable
      services.auto-cpufreq.enable = true;
      services.thermald.enable = true;
      # Powerprofiles seem useless
      services.power-profiles-daemon.enable = false;
    };
}
