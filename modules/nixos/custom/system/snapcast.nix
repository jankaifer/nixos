# Stolen from: https://github.com/sweenu/nixfiles
{ config, lib, pkgs, ... }:
let
  cfg = config.custom.system.snapcast;
in
{
  options.custom.system.snapcast = {
    enable = lib.mkEnableOption "snapcast";
  };

  config = lib.mkIf cfg.enable {
    services.snapserver = {
      enable = true;
      openFirewall = true;
      http = {
        enable = true;
        listenAddress = "0.0.0.0";
        # docRoot = "${/home/pearman/dev/jankaifer/snapweb/dist}";
        docRoot = "${pkgs.snapcast}/share/snapserver/snapweb/";
      };
      streams = {
        Spotify = {
          type = "librespot";
          location = "${pkgs.librespot}/bin/librespot";
          query = {
            devicename = config.custom.options.hostName;
            normalize = "true";
            autoplay = "false";
            cache = "/home/${config.custom.options.username}/.cache/librespot";
            killall = "true";
            params = "--cache-size-limit=4G";
          };
        };
      };
    };

    # pass Spotify credentials to librespot with a file containing:
    # LIBRESPOT_USERNAME=username
    # LIBRESPOT_PASSWORD=password
    systemd.services.snapserver.serviceConfig.EnvironmentFile = [ config.age.secrets.snapserver-env-file.path ];
  };
}
