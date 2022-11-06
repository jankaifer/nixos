{ config, lib, pkgs, ... }:

let
  secrets = import ../secrets { };
in
{
  options.custom.iso =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Is this system bootable ISO image?
        '';
      };
    };

  config =
    lib.mkIf (!config.custom.iso.enable)
      {
        # Use the systemd-boot EFI boot loader.
        boot.loader.grub.useOSProber = false;
        boot.loader.systemd-boot.enable = true;
        boot.loader.efi.canTouchEfiVariables = true;

        # Networking
        networking.networkmanager.enable = true;

        # Setup user
        users.mutableUsers = false;
        users.users.pearman = {
          isNormalUser = true;
          description = "Jan Kaifer";
          extraGroups = [
            "wheel"
            "networkmanager"
            "video"
            "docker"
            "adbusers"
            "lxd"
          ];
          hashedPassword = secrets.hashedPassword;
        };
      };
}
