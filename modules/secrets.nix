{ config, lib, pkgs, ... }:

{
  age.identityPaths = [ "/home/pearman/.ssh/id_ed25519" ];
  age.secrets.login-password.file = ../secrets/login-password.age;
  age.secrets.wifi-passwords.file = ../secrets/wifi-passwords.age;
}
