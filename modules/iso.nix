{ config, lib, pkgs, ... }@args:

{
  options.custom.iso =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Is this system bootable ISO?
        '';
      };
    };

  config = lib.mkIf (!config.custom.iso.enable) {
    # Use the systemd-boot EFI boot loader.
    boot.loader = {
      grub.useOSProber = false;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    # Audio
    sound.enable = true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
  };
}
