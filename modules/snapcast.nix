{ config, lib, pkgs, ... }:
let
  option-name = "snapcast";
in
{
  options.custom."${option-name}" = {
    enable = lib.mkOption {
      default = false;
      example = true;
      description = ''
        Enable snapcast server.
      '';
    };
  };

  config = lib.mkIf config.custom."${option-name}".enable {
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
            devicename = "Snapcast";
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
