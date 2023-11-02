{ lib, config, pkgs, ... }: {
  imports = [
    ../../modules
    ../../modules/raspberry-shared.nix
  ];


  environment.systemPackages = [
    pkgs.snapcast
  ];

  custom = {
    snapcast.enable = true;

    options = {
      hostName = "raspberry-1";
    };
  };
}
