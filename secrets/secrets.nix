let
  ghKeys = import ../modules/publicSshKeys.nix;
in
{
  "wifi-easswords.age".publicKeys = ghKeys;
  "login-password.age".publicKeys = ghKeys;
}
