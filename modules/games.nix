{ config, lib, pkgs, ... }:

{
  options.custom.games =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
      };
    };

  config = lib.mkIf config.custom.games.enable
    {
      # More info on wiki: https://nixos.wiki/wiki/Steam
      programs.steam.enable = true;
    };
}
