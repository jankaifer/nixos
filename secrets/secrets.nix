let
  ghKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKHVIfXNuROWZRJhqcEGW9eohIH5Fg3PblefvMu+JaNw"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDzPJ15GG8/uHf86p7jg0Tud7lZ5rjySwAjlD4ZxEtZn"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID2Yfd6UdZmYwlA9BOJvInQzeAbAKiuukraiNGILAO/R"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGVQQAILmV9csI6tLonpbI5r1WDPDNmJXwQ4LXQS5WXd"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJe9IWxd3nIG9qm86UMTZeVHHeHN5eh6nHu7KwU+x/fz"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIj0bWCoUZGfkwtkVli31sQgI0Ke7N+oWZApSdN3e8tX"
  ];
in
{
  "chatbot-ui-env-file.age".publicKeys = ghKeys;
  "cloudflare-credentials.age".publicKeys = ghKeys;
  "coolify-env-file.age".publicKeys = ghKeys;
  "grafana-password.age".publicKeys = ghKeys;
  "login-password.age".publicKeys = ghKeys;
  "rclone-config-google-drive.age".publicKeys = ghKeys;
  "rclone-config-google-photos.age".publicKeys = ghKeys;
  "restic-backblaze-env-file.age".publicKeys = ghKeys;
  "restic-password.age".publicKeys = ghKeys;
  "restic-wasabi-env-file.age".publicKeys = ghKeys;
  "snapserver/env-file.age".publicKeys = ghKeys;
  "traefik-env.age".publicKeys = ghKeys;
  "wifi-passwords.age".publicKeys = ghKeys;
  "docker-config.age".publicKeys = ghKeys;
}
