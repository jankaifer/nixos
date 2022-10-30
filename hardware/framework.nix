{ pkgs, ... }:

{
  # Enable fingerprint
  services.fprintd.enable = true;

  # Fixes from https://dov.dev/blog/nixos-on-the-framework-12th-gen

  ## Fix brightness keys
  boot.kernelParams = [ "module_blacklist=hid_sensor_hub" ];
}
