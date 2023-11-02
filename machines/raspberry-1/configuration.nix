{ lib, ... }: {
  imports = [
    ../../modules
    ../../modules/raspberry-shared.nix
  ];

  custom = {
    # snapcast.enable = true;

    options = {
      hostName = "raspberry-1";
    };
  };
}
