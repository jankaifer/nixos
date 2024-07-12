{ pkgs, ... }:
{
  custom = {
    gnome = {
      enable = true;
      idleDelay = 0;
      # for some reason nerdfonts can't be build on oldbox
      font = pkgs.noto-fonts;
    };
    vscode.enable = true;
    impermanence.enable = true;
  };
}
