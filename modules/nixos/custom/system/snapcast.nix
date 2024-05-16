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
        docRoot = "${pkgs.snapcast}/share/snapserver/snapweb/";
      };
      streams = {
        Spotify = {
          type = "librespot";
          location = "${pkgs.librespot}/bin/librespot";
          query = {
            devicename = "Snapcast (${config.networking.hostName})";
            normalize = "true";
            autoplay = "false";
            cache = "/home/${config.custom.system.user}/.cache/librespot";
            killall = "true";
            params = "--cache-size-limit=4G";
          };
        };
      };
    };

    # pass Spotify credentials to librespot with a file containing:
    # LIBRESPOT_USERNAME=username
    # LIBRESPOT_PASSWORD=password
    age.secrets.snapserver-env-file.file = ../../../../secrets/snapserver/env-file.age;
    systemd.services.snapserver.serviceConfig.EnvironmentFile = [ config.age.secrets.snapserver-env-file.path ];
  };
}
