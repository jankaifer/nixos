{ config, lib, pkgs, ... }@args:

{
  options.custom.options = {
    username = lib.mkOption {
      default = "nixos";
      example = "jankaifer";
      description = ''
        What's the name of the system user? My configs use only single-user setups.
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
}
