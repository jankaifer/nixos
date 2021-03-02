{ pkgs, toRelativePath }:

with builtins;
let
  mod = "Mod4";

  # These variables are WET in configs/i3.conf
  ws = pkgs.lib.lists.imap1 (index: name: toString index) [
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
  package = pkgs.i3-gaps;
  config = {
    bars = [ ];
    colors = { };
    floating = {
      modifier = mod;
    };
    fonts = [
      "Fira Code Retina 16"
    ];
    gaps = {
      inner = 15;
      smartGaps = true;
    };
    keybindings = { };
    modes = { };
    startup = [
      {
        command = "reload-monitors";
        always = true;
      }
    ];
  };
  extraConfig = (builtins.readFile (toRelativePath "configs/i3.conf")) + "\n" + ''
    assign [class="^zoom$"] ${elemAt ws 6}
  '';
}
