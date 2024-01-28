{ pkgs, config, lib, ... }:

let
  domain = "oldbox.kaifer.cz";
  grafana = {
    port = 8002;
  };
  victoriametrics = {
    port = 8003;
  };
  dailyBackupTimerConfig = {
    OnCalendar = "00:05";
    RandomizedDelaySec = "5h";
  };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  virtualisation.docker.enable = true;
  virtualisation.docker.storageDriver = "btrfs";

  system.stateVersion = "22.05"; # Did you read the comment?
  custom.system = {
    sshd.enable = true;
    impermanence.enable = true;
    gui.enable = true;
    development.enable = true;
    home-manager.home = ../../home-manager/oldbox.nix;
    home-manager.enable = true;
  };

  age.secrets.traefik-env.file = ../../secrets/traefik-env.age;
  age.secrets.grafana-password = {
    file = ../../secrets/grafana-password.age;
    owner = "grafana";
    group = "grafana";
  };

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
          "traefik.http.routers.pihole.entrypoints" = "websecure";
          "traefik.http.services.pihole.loadbalancer.server.port" = "80";
        };
      };
      home-assistant = {
        image = "ghcr.io/home-assistant/home-assistant:2024.1";
        environment.TZ = "Europe/Prague";
        volumes = [ "/persist/containers/home-assistant/config:/config" ];
        labels = {
          "traefik.http.routers.home-assistant.rule" = "Host(`home-assistant.${domain}`)";
          "traefik.http.routers.home-assistant.entrypoints" = "websecure";
          "traefik.http.services.home-assistant.loadbalancer.server.port" = "8123";
        };
      };
    };
  };

  # Erase root partition
  boot.initrd.postDeviceCommands = lib.mkAfter ''
    zfs rollback -r rpool/local/root@blank
  '';

  networking.hostName = "oldbox";

  # Traefik
  # stolen from https://github.com/LongerHV/nixos-configuration/blob/87ac6a7370811698385d4c52fc28fab94addaea2/modules/nixos/homelab/traefik.nix

  networking.firewall.allowedTCPPorts = [ 80 443 ];
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

  systemd.services.traefik.serviceConfig.EnvironmentFile = [ config.age.secrets.traefik-env.path ];
  services.traefik = {
    enable = true;
    group = "docker";
    staticConfigOptions = {
      log.level = "info";
      providers.docker = { };
      api.dashboard = true;
      global = {
        checknewversion = false;
        sendanonymoususage = false;
      };
      accessLog.filePath = "/var/log/traefik/access.log";
      metrics.prometheus.manualRouting = true;
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entryPoint = {
            to = "websecure";
            scheme = "https";
          };
        };
        websecure = {
          address = ":443";
          http.tls = {
            certResolver = "cloudflare";
            domains = [{ main = "${domain}"; sans = [ "*.${domain}" ]; }];
          };
        };
      };
      certificatesResolvers = {
        cloudflare = {
          acme = {
            email = "jan@kaifer.cz";
            storage = "${config.services.traefik.dataDir}/acme.json";
            dnsChallenge = {
              provider = "cloudflare";
              resolvers = [ "1.1.1.1:53" "1.0.0.1:53" ];
            };
          };
        };
      };
    };

    dynamicConfigOptions = {
      http = {
        routers = {
          traefik = {
            rule = "Host(`traefik.${domain}`)";
            service = "api@internal";
            entrypoints = [ "websecure" ];
          };
          traefik-metrics = {
            rule = "Host(`traefik-metrics.${domain}`)";
            service = "prometheus@internal";
            entrypoints = [ "websecure" ];
          };
          grafana = {
            rule = "Host(`grafana.${domain}`)";
            service = "grafana@file";
            entrypoints = [ "websecure" ];
          };
          victoriametrics = {
            rule = "Host(`victoriametrics.${domain}`)";
            service = "victoriametrics@file";
            entrypoints = [ "websecure" ];
          };
        };
        services = {
          grafana.loadBalancer.servers = [
            { url = "http://localhost:${toString grafana.port}"; }
          ];
          victoriametrics.loadBalancer.servers = [
            { url = "http://localhost:${toString victoriametrics.port}"; }
          ];
        };
      };
      middlewares = { };
    };
  };

  services.grafana = {
    enable = true;
    declarativePlugins = with pkgs.grafanaPlugins; [ grafana-piechart-panel ];
    settings = {
      server = {
        domain = "grafana.${domain}";
        http_port = grafana.port;
      };
      analytics = {
        reporting_enabled = false;
        check_for_updates = false;
        check_for_plugin_updates = false;
      };
      security = {
        admin_user = "admin";
        admin_email = "jan@kaifer.cz";
        admin_password = "$__file{${config.age.secrets.grafana-password.path}}";
      };
      panels.disable_sanitize_html = true;
    };
    provision = {
      datasources.settings.datasources = [{
        name = "VictoriaMetrics";
        type = "prometheus";
        uid = "vm";
        access = "proxy";
        url = "http://localhost:${toString victoriametrics.port}";
        isDefault = true;
        version = 1;
        editable = false;
      }];
    };
  };

  services.victoriametrics = {
    enable = true;
    listenAddress = ":${toString victoriametrics.port}";
    extraOptions =
      let
        scrapeConfigFile = builtins.toFile "prometheus-scrape-config.yml" ''
          scrape_configs:
          - job_name: traefik
            static_configs:
            - targets:
              - "https://traefik-metrics.${domain}"
        '';
      in
      [
        # "-promscrape.config.strictParse=false" # required for victoriametrics to parse the config
        "-promscrape.config=${scrapeConfigFile}"
      ];
  };

  # To configure this, you need to create the tunnel locally using `cloudflared tunnel create [tunnel-name]`
  age.secrets.cloudflare-credentials-file = {
    file = ../../secrets/cloudflare-credentials.age;
    owner = "cloudflared";
    group = "cloudflared";
  };
  services.cloudflared = {
    enable = true;
    tunnels."ff121495-6f5b-425f-82ed-a54e06d22ab7" = {
      credentialsFile = config.age.secrets.cloudflare-credentials-file.path;
      default = "http_status:404";
      ingress = {
        "pihole.kaifer.com" = "https://localhost";
        "grafana.kaifer.com" = "https://localhost";
        "traefik.kaifer.com" = "https://localhost";
      };
    };
  };

  systemd.services.hd-idle = {
    description = "HD spin down daemon, spins down disks after 15 minutes of inactivity";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.hd-idle}/bin/hd-idle -i 900";
    };
  };

  # Stop Gnome from suspending, copied from https://discourse.nixos.org/t/stop-pc-from-sleep/5757/2
  systemd.targets.sleep.enable = false;
  systemd.targets.suspend.enable = false;
  systemd.targets.hibernate.enable = false;
  systemd.targets.hybrid-sleep.enable = false;

  age.secrets.restic-password.file = ../../secrets/restic-password.age;
  age.secrets.restic-wasabi-env-file.file = ../../secrets/restic-wasabi-env-file.age;
  services.restic.backups =
    let
      oldboxBackup = {
        passwordFile = config.age.secrets.restic-password.path;
        paths = [ "/persist" ];
        exclude = [
          "/.cache/"
          "/persist/home/*/.cache"
          "/persist/var/lib/docker"
          "/persist/var/lib/private/victoriametrics/cache"
          "/var/cache/"
        ];
      };
      googleDriveBackup = {
        passwordFile = config.age.secrets.restic-password.path;
        paths = [ "/nas/google-drive" ];
      };
      googlePhotosBackup = {
        passwordFile = config.age.secrets.restic-password.path;
        paths = [ "/nas/google-photos" ];
      };
    in
    {
      localOldboxbackup = oldboxBackup // {
        initialize = true;
        repository = "/nas/backups/oldbox";
      };
      remoteOldboxBackup = oldboxBackup // {
        initialize = true;
        repository = "s3:https://s3.eu-central-2.wasabisys.com/jankaifer-oldbox-backup";
        environmentFile = config.age.secrets.restic-wasabi-env-file.path;
        timerConfig = dailyBackupTimerConfig;
      };
      localGoogleDriveBackup = googleDriveBackup // {
        initialize = true;
        repository = "/nas/backups/google-drive";
      };
      remoteGoogleDriveBackup = googleDriveBackup // {
        initialize = true;
        repository = "s3:https://s3.eu-central-2.wasabisys.com/jankaifer-google-drive-backup";
        environmentFile = config.age.secrets.restic-wasabi-env-file.path;
        timerConfig = dailyBackupTimerConfig;
      };
      localGooglephotosBackup = googlePhotosBackup // {
        initialize = true;
        repository = "/nas/backups/google-photos";
      };
      remoteGooglePhotosBackup = googlePhotosBackup // {
        initialize = true;
        repository = "s3:https://s3.eu-central-2.wasabisys.com/jankaifer-google-photos-backup";
        environmentFile = config.age.secrets.restic-wasabi-env-file.path;
        timerConfig = dailyBackupTimerConfig;
      };
    };

  # Mount google drive
  age.secrets.rclone-config-google-drive.file = ../../secrets/rclone-config-google-drive.age;
  systemd.services.rclone-mount-google-drive =
    let
      mountdir = "/nas/google-drive";
    in
    {
      description = "mount google drive";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = "/run/current-system/sw/bin/mkdir -p ${mountdir}";
      script = ''
        ${pkgs.rclone}/bin/rclone mount google-drive: ${mountdir} \
          --config "${config.age.secrets.rclone-config-google-drive.path}" \
          --tpslimit 10
          --dir-cache-time 48h \
          --vfs-cache-mode full \
          --vfs-cache-max-age 48h \
          --vfs-read-chunk-size 10M \
          --vfs-read-chunk-size-limit 512M \
          --no-modtime \
          --buffer-size 512M
      '';
      preStop = "/run/wrappers/bin/umount ${mountdir}";
      environment = {
        PATH = lib.mkForce "${pkgs.fuse3}/bin:$PATH";
      };
    };

  # Mount google photos
  age.secrets.rclone-config-google-photos.file = ../../secrets/rclone-config-google-photos.age;
  systemd.services.rclone-mount-google-photos =
    let
      mountdir = "/nas/google-photos";
    in
    {
      description = "mount google photos";
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = "/run/current-system/sw/bin/mkdir -p ${mountdir}";
      script = ''
        ${pkgs.rclone}/bin/rclone mount google-photos: ${mountdir} \
          --config "${config.age.secrets.rclone-config-google-photos.path}" \
          --tpslimit 1
          --dir-cache-time 48h \
          --vfs-cache-mode full \
          --vfs-cache-max-age 48h \
          --vfs-read-chunk-size 10M \
          --vfs-read-chunk-size-limit 512M \
          --no-modtime \
          --buffer-size 512M
      '';
      preStop = "/run/wrappers/bin/umount ${mountdir}";
      environment = {
        PATH = lib.mkForce "${pkgs.fuse3}/bin:$PATH";
      };
    };
}
