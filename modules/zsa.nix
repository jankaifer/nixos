{ config, lib, pkgs, ... }:

{
  options.custom.zsa =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Add support for ZSA keyboards.
        '';
      };
    };

  config =
    lib.mkIf config.custom.zsa.enable
      {
        hardware.keyboard.zsa.enable = true;
      };
}
