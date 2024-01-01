# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

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
        ports = [ "53:53/tcp" "53:53/udp" "67:67/udp" "80:80/tcp" ];
        environment = {
          TZ = "Europe/Prague";
          WEBPASSWORD = "pihole";
        };
        volumes = [
          "/persist/containers/pihole/etc-pihole:/etc/pihole"
          "/persist/containers/pihole/etc-dnsmasq.d:/etc/dnsmasq.d"
        ];
      };
      # hedgedoc = {
      #   image = "quay.io/hedgedoc/hedgedoc:1.9.6";
      #   volumes = [ "/var/lib/hedgedoc/uploads:/hedgedoc/public/uploads" ];
      #   environmentFiles = [ "/run/secrets/CMD_DB_URL.env" ];
      #   environment = {
      #     CMD_DOMAIN = cfg.hostName;
      #     CMD_URL_ADDPORT = "false";
      #     CMD_PROTOCOL_USESSL = "true";
      #     CMD_PORT = "3001";
      #   };
      #   dependsOn = [ "hedgedoc-postgres" ];
      #   extraOptions = [ "--network=host" ];
      # };
      # hedgedoc-postgres = {
      #   # TODO: upgrade to PG 15
      #   image = "postgres:13.9-alpine";
      #   ports = [ "15432:5432" ];
      #   volumes = [ "/var/lib/hedgedoc/postgres:/var/lib/postgresql/data" ];
      #   environmentFiles = [ "/run/secrets/CMD_DB_URL.env" ];
      # };
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
}
