{ pkgs, toRelativePath, ... }:

with builtins;
let
  mod = "Mod4";

  # These variables are WET in configs/i3.conf
  ws = pkgs.lib.lists.imap0 (index: name: toString index) [
    "private"
    "browser"
    "shell"
    "code"
    "git"
    "universal"
    "zoom"
    "chat"
    "music"
    "universal"
    "universal"
  ];
in
{
  enable = true;
  extraConfig = (builtins.readFile (toRelativePath "configs/i3.conf"));
}
