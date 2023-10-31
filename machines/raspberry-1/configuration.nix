{ lib, ... }: {
  imports = [
    ../../modules
    ../../modules/raspberry-shared.nix
  ];

  custom = {
    options = {
      hostName = "raspberry-1";
    };
  };
}
