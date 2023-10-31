{ config, lib, pkgs, ... }:
let
  option-name = "template";
in
{
  options.custom."${option-name}" = {
    enable = lib.mkOption {
      default = false;
      example = true;
      description = ''
        TEMPLATE
      '';
    };
  };

  config = lib.mkIf config.custom."${option-name}".enable { };
}
