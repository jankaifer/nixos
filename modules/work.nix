{ config, lib, pkgs, ... }:

{
  options.custom.work =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Setup my work environment at Vercel.
        '';
      };
    };

  config =
    lib.mkIf config.custom.work.enable
      {
        custom.falcon.enable = true;
      };
}
