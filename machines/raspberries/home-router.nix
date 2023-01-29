{ lib, ... }: {
  imports = [
    <nixpkgs/nixos/modules/installer/sd-card/sd-image-raspberrypi.nix>
  ];

  users.extraUsers.nixos.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHVIfXNuROWZRJhqcEGW9eohIH5Fg3PblefvMu+JaNw"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEdzynkHX/sNuZW52iVAtzpAr+FbzRYq6oWDzV9KY3Vf"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzPJ15GG8/uHf86p7jg0Tud7lZ5rjySwAjlD4ZxEtZn"
  ];

  # bzip2 compression takes loads of time with emulation, skip it. Enable this if you're low
  # on space.
  sdImage.compressImage = false;

  # OpenSSH is forced to have an empty `wantedBy` on the installer system[1], this won't allow it
  # to be automatically started. Override it with the normal value.
  # [1] https://github.com/NixOS/nixpkgs/blob/9e5aa25/nixos/modules/profiles/installation-device.nix#L76
  systemd.services.sshd.wantedBy = lib.mkOverride 40 [ "multi-user.target" ];

  # Enable OpenSSH out of the box.
  services.sshd.enable = true;

  # Wireless networking (1). You might want to enable this if your Pi is not attached via Ethernet.
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
