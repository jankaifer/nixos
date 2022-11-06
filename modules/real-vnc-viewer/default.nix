{ config, lib, pkgs, ... }:

{
  options.custom.real-vnc-viewer =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to install RealVNC Viewer.
        '';
      };
    };

  config = lib.mkIf config.custom.real-vnc-viewer.enable
    {
      environment.systemPackages = [
        (pkgs.callPackage ./real-vnc-viewer.nix { })
      ];
    };
}
