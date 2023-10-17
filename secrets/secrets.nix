let
  ghKeys = import ../modules/public-ssh-keys.nix;
in
{
  "wifi-passwords.age".publicKeys = ghKeys;
  "login-password.age".publicKeys = ghKeys;
}
