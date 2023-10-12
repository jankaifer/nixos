{ lib, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix>
  ];

  users.extraUsers.nixos.openssh.authorizedKeys.keys = import ../../modules/publicSshKeys.nix;

  users.users.nixos.group = "nixos";
  users.users.nixos.initialPassword = "nixos";
  users.users.nixos.extraGroups = [ "wheel" ];
  users.groups.nixos = { };
  users.users.nixos.isNormalUser = true;

  # We don't need the xserver on the Pi.
  services.xserver.enable = false;
  services.xserver.displayManager.gdm.enable = false;
  services.xserver.desktopManager.gnome.enable = false;

  # bzip2 compression takes loads of time with emulation, skip it. Enable this if you're low
  # on space.
  sdImage.compressImage = false;

  # OpenSSH is forced to have an empty `wantedBy` on the installer system[1], this won't allow it
  # to be automatically started. Override it with the normal value.
  # [1] https://github.com/NixOS/nixpkgs/blob/9e5aa25/nixos/modules/profiles/installation-device.nix#L76
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];

  # Enable OpenSSH out of the box.
  services.sshd.enable = true;

  networking.wireless = {
    enable = true;
    interfaces = [ "wlan0" ];
    networks = {
      "PDK" = {
        psk = "dobrodudosli";
      };
    };
  };

  # Wireless networking (2). Enables `wpa_supplicant` on boot.
  systemd.services.wpa_supplicant.wantedBy = lib.mkOverride 10 [ "default.target" ];

  # NTP time sync.
  services.timesyncd.enable = true;

  system.stateVersion = "23.05";
}
