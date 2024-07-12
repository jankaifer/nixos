{ pkgs, ... }:
{
  custom = {
    gnome = {
      enable = true;
      idleDelay = 0;
      # for some reason nerdfonts can't be build on oldbox
      font = {
        name = "Noto fonts";
        package = pkgs.noto-fonts;
        size = 14;
      };
    };
    vscode.enable = true;
    impermanence.enable = true;
  };
}
