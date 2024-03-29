{ config, lib, ... }:

let
  fontName = config.custom.gnome.font.name;
  fontSize = config.custom.gnome.font.size;
in
{
  config = lib.mkIf config.custom.gnome.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        window = {
          padding = { x = 6; y = 6; };
          opacity = 0.90;
        };
        cursor = {
          thickness = 0.1;
        };
        font = {
          normal = {
            family = fontName;
            style = "Regular";
          };
          bold = {
            family = fontName;
            style = "Bold";
          };
          italic = {
            family = fontName;
            style = "Italic";
          };
          bold_italic = {
            family = fontName;
            style = "Bold Italic";
          };
          size = fontSize;
        };
        colors = {
          inherit (config.custom.colors) primary cursor normal bright;
        };
      };
    };
  };
}
