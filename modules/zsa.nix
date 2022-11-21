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
        # system option is outdated
        hardware.keyboard.zsa.enable = false;

        users.groups = {
          plugdev = { };
        };
        users.users.pearman.extraGroups = [ "plugdev" ];
        services.udev.extraRules = ''
          KERNEL=="hidraw*", ATTRS{idVendor}=="16c0", MODE="0666", GROUP="plugdev"
          KERNEL=="hidraw*", ATTRS{idVendor}=="3297", MODE="0666", GROUP="plugdev"
        '';
      };
}
