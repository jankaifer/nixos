{ config, lib, ... }:

let
  cfg = config.custom.system.sshd;
in
{
  options.custom.system.sshd = {
    enable = lib.mkEnableOption "sshd";
  };

  config = lib.mkIf cfg.enable {
    services.openssh.enable = true;
  };
}
