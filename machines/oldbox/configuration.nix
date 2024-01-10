# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ pkgs, ... }:

let
  domain = "oldbox.kaifer.cz";
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  # We need few volumes to be mounted before our system starts booting
  fileSystems."/var/log".neededForBoot = true;
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/".neededForBoot = true;
  fileSystems."/nix".neededForBoot = true;

  home-manager.users.jankaifer.home.stateVersion = "22.05";

  networking.firewall.enable = false;

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  virtualisation.oci-containers = {
    backend = "docker";
    containers = {
      pihole = {
        image = "pihole/pihole:2023.11.0";
        ports = [
          "53:53/tcp"
          "53:53/udp"
          "67:67/udp"
        ];
        environment = {
          TZ = "Europe/Prague";
          WEBPASSWORD = "pihole";
        };
        volumes = [
          "/persist/containers/pihole/etc-pihole:/etc/pihole"
          "/persist/containers/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
        ];
        labels = {
          "traefik.http.routers.pihole.rule" = "Host(`pihole.${domain}`)";
          "traefik.http.routers.pihole.entrypoints" = "web";
          "traefik.http.services.pihole.loadbalancer.server.port" = "80";
        };
      };
    };
  };

  # Options
  custom = {
    cli-server.enable = true;
    common-workstation.enable = true;
    impermanence.enable = true;
    fck.enable = true;
    ssh-server.enable = true;
    ssh-keys-autogenerate.enable = true;

    options = {
      hostName = "oldbox";
    };
  };

  # Traefik
  # stolen from https://github.com/LongerHV/nixos-configuration/blob/87ac6a7370811698385d4c52fc28fab94addaea2/modules/nixos/homelab/traefik.nix

  networking.firewall.allowedTCPPorts = [ 80 ];
  networking.hosts."127.0.0.1" = [ "traefik.${domain}" ];

  systemd.services.traefik-log-folder = {
    description = "Ensure folder exists for traefik";
    wantedBy = [ "multi-user.target" ];
    script = ''
      #! ${pkgs.bash}/bin/bash
      FOLDER_PATH="/var/log/traefik"
      if [ ! -d "$FOLDER_PATH" ]; then
        mkdir -p "$FOLDER_PATH"
        chown -R traefik:traefik "$FOLDER_PATH"
      fi
    '';
  };

  services.traefik = {
    enable = true;
    group = "docker";
    staticConfigOptions = {
      log.level = "info";
      providers.docker = { };
      entryPoints.web.address = ":80";
      api.dashboard = true;
      api.insecure = true;
      global = {
        checknewversion = false;
        sendanonymoususage = false;
      };
      accessLog.filePath = "/var/log/traefik/access.log";
    };
    dynamicConfigOptions = {
      http = {
        routers = {
          traefik = {
            rule = "Host(`traefik.${domain}`)";
            service = "api@internal";
            entrypoints = [ "web" ];
          };
        };
      };
      middlewares = { };
    };
  };
}
