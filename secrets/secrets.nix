let
  ghKeys = import ../modules/public-ssh-keys.nix;
in
{
  "wifi-passwords.age".publicKeys = ghKeys;
  "login-password.age".publicKeys = ghKeys;
  "snapserver/env-file.age".publicKeys = ghKeys;
  "cloudflare/api-email.age".publicKeys = ghKeys;
  "cloudflare/api-dns-token.age".publicKeys = ghKeys;
}
