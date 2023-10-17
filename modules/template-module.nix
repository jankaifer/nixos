{ config, lib, pkgs, ... }:

{
  options.custom.template =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          TEMPLATE
        '';
      };
    };

  config = lib.mkIf config.custom.template.enable
    { };
}
