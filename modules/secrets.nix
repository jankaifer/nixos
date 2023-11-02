{ config, lib, pkgs, ... }:

{
  age.identityPaths = [
    "/home/${config.custom.options.username}/.ssh/id_ed25519"
    # if using impermanence it might have not loaded yet
    "/persist/home/${config.custom.options.username}/.ssh/id_ed25519"
  ];
  age.secrets.login-password.file = ../secrets/login-password.age;
  age.secrets.wifi-passwords.file = ../secrets/wifi-passwords.age;
  age.secrets.snapserver-env-file.file = ../secrets/snapserver/env-file.age;
}
