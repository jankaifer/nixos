{ pkgs, config, lib, ... }:

let
  localDomain = "hobitin.eu";
  services = {
    home-assistant = {
      domain = "ha.${localDomain}";
    };
    grafana = {
      port = "8002";
      domain = "grafana.${localDomain}";
    };
    victoriametrics = {
      port = "8003";
      domain = "vm.${localDomain}";
      scrapeInterval = "5s";
    };
    restic = {
      port = "8004";
      domain = "restic.${localDomain}";
    };
    prometheusNodeCollector = {
      port = "8005";
      domain = "prometheus-node-collector.${localDomain}";
    };
    loki = {
      port = "8006";
      domain = "loki.${localDomain}";
    };
    promtail = {
      port = "8007";
      domain = "promtail.${localDomain}";
    };
    jellyfin = {
      port = "8096";
      domain = "jellyfin.${localDomain}";
    };
    snapcast = {
      port = "1780";
      domain = "snapcast.${localDomain}";
    };
    traefik = {
      domain = "traefik.${localDomain}";
    };
    traefik-metrics = {
      domain = "traefik-metrics.${localDomain}";
    };
    frigate = {
      domain = "frigate.${localDomain}";
    };
  };
  domains = lib.mapAttrsToList (name: service: service.domain) services;
  websocketPort = 444;
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
    # gui.enable = true;
    # development.enable = true;
    home-manager.home = ../../home-manager/oldbox.nix;
    home-manager.enable = true;
    # snapcast.enable = true;
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
      home-assistant = {
        image = "ghcr.io/home-assistant/home-assistant:2024.12.5";
        environment.TZ = "Europe/Prague";
        volumes = [
          "/persist/containers/home-assistant/config:/config"
          "/etc/localtime:/etc/localtime:ro"
        ];
        labels = {
          "traefik.http.routers.home-assistant.rule" = "Host(`${services.home-assistant.domain}`)";
          "traefik.http.routers.home-assistant.entrypoints" = "https";
          "traefik.http.services.home-assistant.loadbalancer.server.port" = "8123";
        };
        extraOptions = [
          "--network=host"
          # Forward usb devices, we need to pick correct device name
          # "--device=/dev/ttyACM0:/dev/ttyACM0"
          "--device=/dev/ttyUSB0:/dev/ttyUSB0"
        ];
      };
      frigate = {
        image = "ghcr.io/blakeblackshear/frigate:0.15.0";
        volumes =
          let
            configFile = pkgs.writeText "config.yml"
              ''
                mqtt:
                  enabled: False

                tls:
                  enabled: False

                cameras:
                  dummy_camera: # <--- this will be changed to your actual camera later
                    enabled: False
                    ffmpeg:
                      inputs:
                        - path: rtsp://127.0.0.1:554/rtsp
                          roles:
                            - detect
              '';
          in
          [
            "/persist/containers/frigate/config:/config"
            "${configFile}:/frigate_config.yml"
            "/nas/frigate:/media/frigate"
          ];
        environment = {
          FRIGATE_CONFIG_FILE = "/frigate_config.yml";
        };
        extraOptions = [
          "--tmpfs=/tmp/cache:rw,size=1000000000" # 1GB of memory, reduces SSD/SD Card wear
        ];
        labels = {
          "traefik.http.routers.frigate.rule" = "Host(`${services.frigate.domain}`)";
          "traefik.http.routers.frigate.entrypoints" = "https";
          "traefik.http.services.frigate.loadbalancer.server.port" = "8971";
        };
        ports = [
          "8554:8554" # RTSP feeds
          "8555:8555/tcp" # WebRTC over tcp
          "8555:8555/udp" # WebRTC over udp
        ];
      };
    };
  };

  # Erase root partition
  boot.initrd.postDeviceCommands = lib.mkBefore ''
    mount -o subvol=/ /dev/disk/by-label/nixos /mnt

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

  networking.firewall.allowedTCPPorts = [
    # Traefik
    80
    443
    websocketPort
  ];
  networking.hosts."127.0.0.1" = domains;

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
  systemd.services.traefik-data-folder = {
    description = "Ensure folder has correct permissions for traefik";
    wantedBy = [ "traefik.service" ];
    script = ''
      #! ${pkgs.bash}/bin/bash
      FOLDER_PATH="/var/lib/traefik"
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
      entryPoints =
        let
          tls = {
            certResolver = "letsencrypt";
            domains = [
              { main = "hobitin.eu"; sans = [ "*.hobitin.eu" ]; }
            ];
          };
        in
        {
          http = {
            address = ":80";
            http.redirections.entryPoint = {
              to = "https";
              scheme = "https";
            };
          };
          https = {
            address = ":443";
            http.tls = tls;
          };
          websocket = {
            address = ":${toString websocketPort}";
            http.tls = tls;
          };
        };
      certificatesResolvers = {
        letsencrypt = {
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
            rule = "Host(`${services.traefik.domain}`)";
            service = "api@internal";
            entrypoints = [ "https" ];
          };
          traefik-metrics = {
            rule = "Host(`${services.traefik-metrics.domain}`)";
            service = "prometheus@internal";
            entrypoints = [ "https" ];
          };
          grafana = {
            rule = "Host(`${services.grafana.domain}`)";
            service = "grafana@file";
            entrypoints = [ "https" ];
          };
          victoriametrics = {
            rule = "Host(`${services.victoriametrics.domain}`)";
            service = "victoriametrics@file";
            entrypoints = [ "https" ];
          };
          jellyfin = {
            rule = "Host(`${services.jellyfin.domain}`)";
            service = "jellyfin@file";
            entrypoints = [ "https" ];
          };
          snapcast = {
            rule = "Host(`${services.snapcast.domain}`)";
            service = "snapcast@file";
            entrypoints = [ "https" ];
          };
        };
        services = {
          grafana.loadBalancer.servers = [
            { url = "http://localhost:${services.grafana.port}"; }
          ];
          victoriametrics.loadBalancer.servers = [
            { url = "http://localhost:${services.victoriametrics.port}"; }
          ];
          jellyfin.loadBalancer.servers = [
            { url = "http://localhost:${services.jellyfin.port}"; }
          ];
          snapcast.loadBalancer.servers = [
            { url = "http://localhost:${services.snapcast.port}"; }
          ];
        };
      };
      middlewares = { };
    };
  };

  services.grafana = {
    enable = true;
    declarativePlugins = [ ];
    settings = {
      log = {
        mode = "console file";
        level = "debug";
      };
      server = {
        domain = services.grafana.domain;
        http_port = builtins.fromJSON services.grafana.port;
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
      datasources.settings = {
        apiVersion = 1;
        datasources = [
          {
            name = "VictoriaMetrics";
            type = "prometheus";
            uid = "vm";
            access = "proxy";
            url = "https://${services.victoriametrics.domain}";
            isDefault = true;
            version = 1;
            editable = false;
            jsonData.timeInterval = services.victoriametrics.scrapeInterval;
          }
          {
            name = "Loki";
            type = "loki";
            uid = "loki";
            access = "proxy";
            url = "https://${services.loki.domain}";
            isDefault = false;
            version = 1;
            editable = false;
          }
        ];
      };
    };
  };

  services.victoriametrics = {
    enable = true;
    listenAddress = ":${services.victoriametrics.port}";
    extraOptions =
      let
        scrapeConfigFile = builtins.toFile "prometheus-scrape-config.yml" ''
          global:
            scrape_interval: ${services.victoriametrics.scrapeInterval}

          scrape_configs:
          - job_name: traefik
            static_configs:
            - targets:
              - "https://${services.traefik-metrics.domain}"
          - job_name: restic
            static_configs:
            - targets:
              - "http://localhost:${services.restic.port}"
          - job_name: node_exporter
            static_configs:
            - targets:
              - "http://localhost:${services.prometheusNodeCollector.port}"
          - job_name: home-assistant
            static_configs:
            - targets:
              - "https://${services.home-assistant.domain}/api/prometheus"
        '';
      in
      [
        "-promscrape.config=${scrapeConfigFile}"
      ];
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
      listenAddress = services.restic.port;
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
            "/persist/home/*/.cursor-server"
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
      wants = [ "network-online.target" ];
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
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      preStart = "/run/current-system/sw/bin/mkdir -p ${mountdir}";
      script = ''
        ${pkgs.rclone}/bin/rclone mount google-photos: ${mountdir} \
          --config "${config.age.secrets.rclone-config-google-photos.path}" \
          --tpslimit 2 \
          --dir-cache-time 48h \
          --poll-interval 24h \
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
    wants = [ "network-online.target" ];
    script =
      let
        exportToVmScript = pkgs.writeText "export.js" ''
          const vmUrl = "https://${services.victoriametrics.domain}/api/v1/import/prometheus";

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
    port = builtins.fromJSON services.prometheusNodeCollector.port;
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
    # package = pkgs.grafana-loki;
    extraFlags = [
      # "--log.level=debug"
    ];
    configuration = {
      auth_enabled = false;

      server.http_listen_port = builtins.fromJSON services.loki.port;

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
    after = [ "users.target" ];
    wants = [ "users.target" ];
    script = ''
      #! ${pkgs.bash}/bin/bash
      set -x  # Print commands as they execute

      FOLDER_PATH="/var/log/promtail"
      if [ ! -d "$FOLDER_PATH" ]; then
        mkdir -p "$FOLDER_PATH" || { echo "Failed to create directory"; exit 1; }
      fi
      chown -R promtail:promtail "$FOLDER_PATH" || { echo "Failed to set ownership"; exit 1; }
    '';
  };

  services.promtail = {
    enable = true;
    configuration = {
      server = {
        http_listen_port = services.promtail.port;
        grpc_listen_port = 0;
      };

      positions.filename = "/var/log/promtail/positions.yaml";

      clients = [
        { url = "https://${services.loki.domain}/loki/api/v1/push"; }
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

  # Add Coolify
  # Coolify needs root login
  services.openssh.settings.PermitRootLogin = "prohibit-password";
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCdae7j5X3pyHPTqeRcEyz/Sqjhe5zro0jmicwiHONSp/0UWTRE2l2uOlgzw6/5T2da8Jxr53MsPrEH/t9jAlZf+pt7xKgJWm7KYWJKJn5ipBil66lQoI4Hdh1E4fFdz8YmZYOis24GFntPc9sqszyDmrG3RuHsR6HPBN01AUAFNykoFOc/eDQ6iExXo2CGtfgtq7EQvp8AhLt7+yFcqdUaXsdokqDFfTJKrUpWyo6wrK9k0lP8aCR8Y8O5pwRdKgH3ocQ9f/+2tVgimMZ3L7Xf7cHH/pxqjYdwM3FpNw9hWbD7XCHYj/kI7lTiX3+uaRRkI4WHGa4SpyhxNpPPubA1 coolify-generated-ssh-key"
  ];
}
