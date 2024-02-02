{ inputs, pkgs, config, lib, ... }:

let
  domain = "oldbox.kaifer.cz";
  grafana = {
    port = 8002;
  };
  victoriametrics = {
    port = 8003;
  };
  restic = {
    port = 8004;
  };
  prometheusNodeCollector = {
    port = 8005;
  };
  loki = {
    port = 8006;
  };
  promtail = {
    port = 8007;
  };
  jellyfin = {
    port = 8096;
  };
  dailyBackupTimerConfig = {
    OnCalendar = "00:05";
    RandomizedDelaySec = "5h";
  };
  cloudflare = {
    tunnelId = "ff121495-6f5b-425f-82ed-a54e06d22ab7";
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
  age.secrets.chatbot-ui-env-file.file = ../../secrets/chatbot-ui-env-file.age;

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
          "traefik.http.routers.pihole.rule" = "Host(`pihole-${domain}`)";
          "traefik.http.routers.pihole.entrypoints" = "websecure";
          "traefik.http.services.pihole.loadbalancer.server.port" = "80";
        };
      };
      home-assistant = {
        image = "ghcr.io/home-assistant/home-assistant:2024.1";
        environment.TZ = "Europe/Prague";
        volumes = [
          "/persist/containers/home-assistant/config:/config"
          "/etc/localtime:/etc/localtime:ro"
        ];
        labels = {
          "traefik.http.routers.home-assistant.rule" = "Host(`home-assistant-${domain}`)";
          "traefik.http.routers.home-assistant.entrypoints" = "websecure";
          "traefik.http.services.home-assistant.loadbalancer.server.port" = "8123";
        };
        extraOptions = [
          "--network=host"
          "--device=/dev/ttyACM0:/dev/ttyACM0" # Forward usb devices
        ];
      };
      chatbot-ui = {
        image = "ghcr.io/mckaywrigley/chatbot-ui:main";
        environmentFiles = [ config.age.secrets.chatbot-ui-env-file.path ];
        labels = {
          "traefik.http.routers.chatbot-ui.rule" = "Host(`chatbot-ui-${domain}`)";
          "traefik.http.routers.chatbot-ui.entrypoints" = "websecure";
          "traefik.http.services.chatbot-ui.loadbalancer.server.port" = "3000";
        };
      };
    };
  };

  # Erase root partition
  boot.initrd.postDeviceCommands = lib.mkBefore ''
    # I copied this from https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html
    mkdir -p /mnt

    # We first mount the btrfs root to /mnt
    # so we can manipulate btrfs subvolumes.
    mount -o subvol=/ /dev/disk/by-label/nixos /mnt

    # While we're tempted to just delete /root and create
    # a new snapshot from /root-blank, /root is already
    # populated at this point with a number of subvolumes,
    # which makes `btrfs subvolume delete` fail.
    # So, we remove them first.
    #
    # /root contains subvolumes:
    # - /root/var/lib/portables
    # - /root/var/lib/machines
    #
    # I suspect these are related to systemd-nspawn, but
    # since I don't use it I'm not 100% sure.
    # Anyhow, deleting these subvolumes hasn't resulted
    # in any issues so far, except for fairly
    # benign-looking errors from systemd-tmpfiles.
    btrfs subvolume list -o /mnt/root |
    cut -f9 -d' ' |
    while read subvolume; do
      echo "deleting /$subvolume subvolume..."
      btrfs subvolume delete "/mnt/$subvolume"
    done &&
    echo "deleting /root subvolume..." &&
    btrfs subvolume delete /mnt/root

    echo "restoring blank /root subvolume..."
    btrfs subvolume snapshot /mnt/root-blank /mnt/root

    # Once we're done rolling back to a blank snapshot,
    # we can unmount /mnt and continue on the boot process.
    umount /mnt
  '';

  networking.hostName = "oldbox";

  # Traefik
  # stolen from https://github.com/LongerHV/nixos-configuration/blob/87ac6a7370811698385d4c52fc28fab94addaea2/modules/nixos/homelab/traefik.nix

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.hosts."127.0.0.1" = [ "traefik-${domain}" ];

  systemd.services.traefik-log-folder = {
    description = "Ensure folder exists for traefik";
    wantedBy = [ "traefik.service" ];
    script = ''
      #! ${pkgs.bash}/bin/bash
      FOLDER_PATH="/var/log/traefik"
      if [ ! -d "$FOLDER_PATH" ]; then
        mkdir -p "$FOLDER_PATH"
      fi
      chown -R traefik:traefik "$FOLDER_PATH"
    '';
  };

  systemd.services.traefik.serviceConfig.EnvironmentFile = [ config.age.secrets.traefik-env.path ];
  services.traefik = {
    enable = true;
    group = "docker";
    dataDir = "/var/lib/traefik";
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
            domains = [{ main = "kaifer.cz"; sans = [ "*.kaifer.cz" ]; }];
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
            rule = "Host(`traefik-${domain}`)";
            service = "api@internal";
            entrypoints = [ "websecure" ];
          };
          traefik-metrics = {
            rule = "Host(`traefik-metrics-${domain}`)";
            service = "prometheus@internal";
            entrypoints = [ "websecure" ];
          };
          grafana = {
            rule = "Host(`grafana-${domain}`)";
            service = "grafana@file";
            entrypoints = [ "websecure" ];
          };
          victoriametrics = {
            rule = "Host(`victoriametrics-${domain}`)";
            service = "victoriametrics@file";
            entrypoints = [ "websecure" ];
          };
          jellyfin = {
            rule = "Host(`jellyfin-${domain}`)";
            service = "jellyfin@file";
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
          jellyfin.loadBalancer.servers = [
            { url = "http://localhost:${toString jellyfin.port}"; }
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
        domain = "grafana-${domain}";
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
      datasources.settings.datasources = [
        {
          name = "VictoriaMetrics";
          type = "prometheus";
          uid = "vm";
          access = "proxy";
          url = "http://localhost:${toString victoriametrics.port}";
          isDefault = true;
          version = 1;
          editable = false;
        }
        {
          name = "Loki";
          type = "loki";
          uid = "loki";
          access = "proxy";
          url = "http://localhost:${toString loki.port}";
          isDefault = false;
          version = 1;
          editable = false;
        }
      ];
    };
  };

  services.victoriametrics = {
    enable = true;
    listenAddress = ":${toString victoriametrics.port}";
    extraOptions =
      let
        scrapeConfigFile = builtins.toFile "prometheus-scrape-config.yml" ''
          global:
            scrape_interval: 10s

          scrape_configs:
          - job_name: traefik
            static_configs:
            - targets:
              - "https://traefik-metrics-${domain}"
          - job_name: restic
            static_configs:
            - targets:
              - "http://localhost:${toString restic.port}"
          - job_name: node_exporter
            static_configs:
            - targets:
              - "http://localhost:${toString prometheusNodeCollector.port}"
          - job_name: home-assistant
            static_configs:
            - targets:
              - "https://home-assistant-${domain}/api/prometheus"
       
        '';
      in
      [
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

    tunnels.${cloudflare.tunnelId} = {
      credentialsFile = config.age.secrets.cloudflare-credentials-file.path;
      default = "http_status:404";
      ingress = {
        "pihole-${domain}" = "https://pihole-${domain}";
        "grafana-${domain}" = "https://grafana-${domain}";
        "traefik-${domain}" = "https://traefik-${domain}";
        "home-assistant-${domain}" = "https://home-assistant-${domain}";
        "ssh-${domain}" = "ssh://localhost:22";
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
  age.secrets.restic-backblaze-env-file.file = ../../secrets/restic-backblaze-env-file.age;
  services.restic = {
    server = {
      enable = true;
      prometheus = true;
      listenAddress = ":${toString restic.port}";
      extraFlags = [
        # We don't allow auth. We use the server only for prometheus metrics export
        "--htpasswd-file=${pkgs.writeText ".htpasswd" ""}"
        "--prometheus-no-auth"
      ];
    };
    backups =
      let
        oldboxBackup = {
          passwordFile = config.age.secrets.restic-password.path;
          paths = [ "/persist" ];
          exclude = [
            "/.cache/"
            "/persist/home/*/.cache"
            "/persist/home/*/.vscode-server"
            "/persist/var/lib/docker"
            "/persist/var/lib/private/victoriametrics/cache"
            "/var/cache/"
          ];
        };
        googleDriveBackup = {
          passwordFile = config.age.secrets.restic-password.path;
          paths = [ "/nas/google-drive" ];
          exclude = [
            # There is a lot of stuff I don't care about, like movies
            "/nas/google-drive/Backup/Backup Goran"
          ];
        };
        googlePhotosBackup = {
          passwordFile = config.age.secrets.restic-password.path;
          paths = [ "/nas/google-photos" ];
        };
        getBackblazeS3Url = bucketName: "s3:s3.eu-central-003.backblazeb2.com/${bucketName}";
      in
      {
        localOldboxBackup = oldboxBackup // {
          initialize = true;
          repository = "/nas/backups/oldbox";
        };
        remoteOldboxBackup = oldboxBackup // {
          initialize = true;
          repository = getBackblazeS3Url "jankaifer-oldbox-backup";
          environmentFile = config.age.secrets.restic-backblaze-env-file.path;
          timerConfig = dailyBackupTimerConfig;
        };
        localGoogleDriveBackup = googleDriveBackup // {
          initialize = true;
          repository = "/nas/backups/google-drive";
        };
        remoteGoogleDriveBackup = googleDriveBackup // {
          initialize = true;
          repository = getBackblazeS3Url "jankaifer-google-drive-backup";
          environmentFile = config.age.secrets.restic-backblaze-env-file.path;
          timerConfig = dailyBackupTimerConfig;
        };
        localGooglePhotosBackup = googlePhotosBackup // {
          initialize = true;
          repository = "/nas/backups/google-photos";
        };
        remoteGooglePhotosBackup = googlePhotosBackup // {
          initialize = true;
          repository = getBackblazeS3Url "jankaifer-google-photos-backup";
          environmentFile = config.age.secrets.restic-backblaze-env-file.path;
          timerConfig = dailyBackupTimerConfig;
        };
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
          --tpslimit 10 \
          --dir-cache-time 48h \
          --vfs-cache-mode full \
          --vfs-cache-max-age 1w \
          --vfs-read-chunk-size 10M \
          --vfs-read-chunk-size-limit 512M \
          --no-modtime \
          --buffer-size 512M
      '';
      preStop = "/run/wrappers/bin/umount ${mountdir}";
      environment = {
        PATH = lib.mkForce "${pkgs.fuse3}/bin:$PATH";
        TMPDIR = "/nas/cache";
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
          --tpslimit 3 \
          --dir-cache-time 48h \
          --vfs-cache-mode full \
          --vfs-cache-max-age 1w \
          --vfs-read-chunk-size 10M \
          --vfs-read-chunk-size-limit 512M \
          --no-modtime \
          --buffer-size 512M
      '';
      preStop = "/run/wrappers/bin/umount ${mountdir}";
      environment = {
        PATH = lib.mkForce "${pkgs.fuse3}/bin:$PATH";
        TMPDIR = "/nas/cache";
      };
    };

  systemd.services.cfspeedtest-metric-exporter = {
    description = "Measure internet speed with cfspeedtest and export to victoriametrics";
    after = [ "network-online.target" ];
    script =
      let
        exportToVmScript = pkgs.writeText "export.js" ''
          const vmUrl = "https://victoriametrics-${domain}/api/v1/import/prometheus";

          const data = JSON.parse(await Bun.stdin.text());
          console.log("We got the following data from speed test:");
          console.log(data);
          console.log();

          const serializeTest = (testData) => ["min", "q1", "median", "q3", "max", "avg"]
            .map(percentile => [
                'cf_speed_test_',
                testData.test_type.toLowerCase(),
                '_',
                percentile,
                '{payload_size="',
                testData.payload_size,
                '"} ',
                testData[percentile],
              ].map(String).join("")
            ).join("\n");
          const metrics = data.map(serializeTest).join("\n");

          console.log("Uploading to ", vmUrl);
          console.log("Metrics being uploaded:");
          console.log(metrics);
          console.log();

          await fetch(vmUrl, {
              method: 'POST',
              headers: {
                  'Content-Type': 'text/plain',
              },
              body: metrics.trim(),
          });

          console.log("Done");
        '';
      in
      ''
        '${pkgs.cfspeedtest}/bin/cfspeedtest' -o json | ${pkgs.bun}/bin/bun '${exportToVmScript}'
      '';
  };

  systemd.timers.cfspeedtest-metric-exporter = {
    description = "Timer for the cfspeedtest-metric-exporter service";
    wantedBy = [ "timers.target" ];
    partOf = [ "cfspeedtest-metric-exporter.service" ];
    timerConfig = {
      OnCalendar = "hourly";
      Persistent = true;
    };
  };

  services.prometheus.exporters.node = {
    enable = true;
    enabledCollectors = [ "systemd" ];
    port = prometheusNodeCollector.port;
  };

  systemd.services.loki-data-folder = {
    description = "Ensure folder exists for loki";
    wantedBy = [ "loki.service" ];
    script = ''
      #! ${pkgs.bash}/bin/bash
      FOLDER_PATH="/var/log/loki"
      if [ ! -d "$FOLDER_PATH" ]; then
        mkdir -p "$FOLDER_PATH"
      fi
      chown -R loki:loki "$FOLDER_PATH"
    '';
  };

  # Loki and promtail setup stolen from https://xeiaso.net/blog/prometheus-grafana-loki-nixos-2020-11-20/
  services.loki = {
    enable = true;
    extraFlags = [
      # "--log.level=debug"
    ];
    configuration = {
      auth_enabled = false;

      server.http_listen_port = loki.port;

      ingester = {
        lifecycler = {
          address = "0.0.0.0";
          ring = {
            kvstore.store = "inmemory";
            replication_factor = 1;
          };
          final_sleep = "0s";
        };
        chunk_idle_period = "1h"; # Any chunk not receiving new logs in this time will be flushed
        max_chunk_age = "1h"; # All chunks will be flushed when they hit this age, default is 1h
        chunk_target_size = 1048576; # Loki will attempt to build chunks up to 1.5MB, flushing first if chunk_idle_period or max_chunk_age is reached first
        chunk_retain_period = "30s"; # Must be greater than index read cache TTL if using an index cache (Default index read cache TTL is 5m)
        max_transfer_retries = 0; # Chunk transfers disabled
      };

      storage_config = {
        filesystem.directory = "/var/log/loki/filesystem";
        boltdb_shipper = {
          active_index_directory = "/var/log/loki/boltdb_shipper/active_index_directory";
          cache_location = "/var/log/loki/boltdb_shipper/cache";
        };
      };
      compactor.working_directory = "/var/log/loki/compactor";

      schema_config = {
        configs = [
          {
            from = "2024-01-01";
            store = "boltdb-shipper";
            object_store = "filesystem";
            schema = "v11";
            index = {
              prefix = "index_";
              period = "24h";
            };
          }
        ];
      };

      limits_config = {
        reject_old_samples = true;
        reject_old_samples_max_age = "168h";
      };

      chunk_store_config = {
        max_look_back_period = "0s";
      };

      table_manager = {
        retention_deletes_enabled = false;
        retention_period = "0s";
      };
    };
  };

  systemd.services.promtail-data-folder = {
    description = "Ensure folder exists for promtail";
    wantedBy = [ "promtail.service" ];
    script = ''
      #! ${pkgs.bash}/bin/bash
      FOLDER_PATH="/var/log/promtail"
      if [ ! -d "$FOLDER_PATH" ]; then
        mkdir -p "$FOLDER_PATH"
      fi
      chown -R promtail:promtail "$FOLDER_PATH"
    '';
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = promtail.port;
        grpc_listen_port = 0;
      };

      positions.filename = "/var/log/promtail/positions.yaml";

      clients = [
        { url = "http://127.0.0.1:${toString loki.port}/loki/api/v1/push"; }
      ];

      scrape_configs = [
        {
          job_name = "journal";
          journal = {
            max_age = "12h";
            labels = {
              job = "systemd-journal";
              host = "oldbox";
            };
          };
          relabel_configs = [{
            source_labels = [ "__journal__systemd_unit" ];
            target_label = "unit";
          }];
        }
        {
          job_name = "system";
          pipeline_stages = [ ];
          static_configs = [
            {
              labels = {
                job = "traefik-access-log";
                host = "oldbox";
                __path__ = "/var/log/traefik/access.log";
              };
            }
            {
              labels = {
                job = "mullvad";
                host = "oldbox";
                __path__ = "/var/log/mullvad-vpn/daemon.log";
              };
            }
            {
              labels = {
                job = "jellyfin";
                host = "oldbox";
                __path__ = "/var/lib/jellyfin/log";
              };
            }
          ];
        }
      ];
    };
  };

  systemd.services."librechat" = {
    script = ''
      ${pkgs.docker-compose}/bin/docker-compose -f '${inputs.libreChat}/docker-compose.yml'
    '';
    wantedBy = [ "multi-user.target" ];
    after = [ "docker.service" "docker.socket" ];
    serviceConfig = {
      Restart = "always";
      RestartSec = "30";
    };
    environment = { };
  };

  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # Enable hardware acceleration for jellyfin, taken from https://nixos.wiki/wiki/Jellyfin
  nixpkgs.config.packageOverrides = pkgs: {
    vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
  };
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      vaapiIntel
      vaapiVdpau
      libvdpau-va-gl
      intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
    ];
  };
}
