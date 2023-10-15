{ config, lib, pkgs, ... }:

{
  age.secrets.login-password.file = ../secrets/login-password.age;
  age.secrets.wifi-passwords.file = ../secrets/wifi-passwords.age;
}
