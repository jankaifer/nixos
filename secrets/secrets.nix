let
  ghKeys = import ../modules/publicSshKeys.nix;
in
{
  "wifi-passwords.age".publicKeys = ghKeys;
  "login-password.age".publicKeys = ghKeys;
}
