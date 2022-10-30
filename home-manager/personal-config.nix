{ pkgs, mypkgs, ... }@args:

with builtins;
{
  home-manager.users.pearman.home = {
    packages = with pkgs; [
      (makeDesktopItem {
        name = "realvnc-viewer";
        desktopName = "Real VNC Viewer";
        exec = "${mypkgs.real-vnc-viewer}/bin/realvnc-viewer";
      })
    ];
  };
}
