{ config, lib, pkgs, ... }@args:

let
  all-machine-configs = import ./all-machine-configs.nix;
in
{
  options.custom.options = {
    username = lib.mkOption {
      default = "nixos";
      example = "jankaifer";
      description = ''
        What's the name of the system user? My configs use only single-user setups.
      '';
    };

    hostName = lib.mkOption {
      default = "computer";
      example = "jans-laptop";
      description = ''
        The hostname of the system.
      '';
    };

    wallpaper-uri = lib.mkOption {
      default = "file://" + ../wallpapers/nix-wallpaper-simple-dark-gray.png;
      example = "file://some/path/with/wallpaper.png";
      description = ''
        Wallpaper used.
      '';
    };
  };

  config.custom.options = {
    username = all-machine-configs."${config.custom.options.hostName}".username;
  };
}
