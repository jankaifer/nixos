{ config, lib, pkgs, ... }:

{
  options.custom.falcon =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to install Falcon CrowdStrike.
        '';
      };
    };

  config = lib.mkIf config.custom.falcon.enable
    {
      environment.systemPackages = [
        (pkgs.callPackage ./falcon.nix { })
      ];
    };
}
