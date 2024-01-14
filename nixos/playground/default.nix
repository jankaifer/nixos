{ lib, ... }:

{
  boot.isContainer = true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  networking = {
    hostName = "playground";
    useDHCP = false;
    useHostResolvConf = false;
    resolvconf.enable = true;
    resolvconf.extraConfig = ''
      resolv_conf_local_only=NO
      name_server_blacklist=127.0.0.1
      name_servers=1.1.1.1
    '';
  };
  security.sudo.wheelNeedsPassword = false;
  system.stateVersion = "23.11";
  nix.gc.automatic = false;

  # custom.system.gui.enable = true;
}
