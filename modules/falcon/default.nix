{ config, lib, pkgs, ... }:

# Copied from: https://gist.github.com/spinus/be0ca03def0c856ada86b16d1727d09d

{
  options.custom.falcon =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to install Falcon CrowdStrike.
        '';
      };
    };

  config =
    let
      falcon = import ./falcon.nix { inherit pkgs lib; };
      falcon-env = pkgs.buildFHSUserEnv {
        name = "falcon-sensor";
        targetPkgs = pkgs: [ pkgs.libnl pkgs.openssl ];
        runScript = "bash";
      };
    in
    lib.mkIf config.custom.falcon.enable
      {
        environment.systemPackages = [ falcon ];
        systemd.services.falcon-sensor = {
          enable = false;
          description = "CrowdStrike Falcon Sensor";
          after = [ "local-fs.target" ];
          conflicts = [ "shutdown.target" ];
          before = [ "shutdown.target" ];
          serviceConfig = {
            WorkingDirectory = "/opt/CrowdStrike";
            ExecStartPre = [
              (pkgs.writeScript "falcon-init" ''
                #!${pkgs.bash}/bin/bash
                set -euo
                rm -rf /opt/CrowdStrike && mkdir -p /opt/CrowdStrike && cp -r ${falcon}/opt/CrowdStrike/* /opt/CrowdStrike/
              '')
              "/opt/CrowdStrike/falconctl -s -f --cid=XXXXXXXXXXXXXXXXXXXXXXXX"
            ];
            ExecStart = "${falcon-env}/bin/falcon-sensor -c /opt/CrowdStrike/falcond";
            Type = "forking";
            PIDFile = "/run/falcond.pid";
            Restart = "no";
            TimeoutStopSec = "60s";
            KillMode = "control-group";
            KillSignal = "SIGTERM";
          };
          wantedBy = [ "multi-user.target" ];
        };
      };
}
