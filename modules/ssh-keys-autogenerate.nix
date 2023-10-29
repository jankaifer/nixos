{ config, lib, pkgs, ... }:

{
  options.custom.ssh-keys-autogenerate =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Whether to automatically create SSH keys on system install.
        '';
      };
    };

  config = lib.mkIf config.custom.ssh-keys-autogenerate.enable
    {
      services.openssh.hostKeys = [
        {
          path = "/home/nixos/.ssh/id_ed25519";
          type = "ed25519";
        }
        i
      ];
    };
}
