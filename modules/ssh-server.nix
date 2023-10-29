{ config, lib, pkgs, ... }:

{
  options.custom.ssh-server =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether unable ssh server with my public keys.
        '';
      };
    };

  config = lib.mkIf config.custom.ssh-server.enable
    {
      services.openssh.enable = true;
      users.users."${config.custom.options.username}".openssh.authorizedKeys.keys = import ./public-ssh-keys.nix;
    };
}
