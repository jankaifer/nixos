{ config, lib, pkgs, ... }:

{
  age.identityPaths =
    if config.custom.impermanence.enable then [
      "/persist/home/${config.custom.options.username}/.ssh/id_ed25519"
    ] else [
      "/home/${config.custom.options.username}/.ssh/id_ed25519"
    ];
  age.secrets.login-password.file = ../secrets/login-password.age;
  age.secrets.wifi-passwords.file = ../secrets/wifi-passwords.age;
  age.secrets.snapserver-env-file.file = ../secrets/snapserver/env-file.age;
}
