{ config, lib, pkgs, ... }:

{
  options.custom.games =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
      };
    };

  config = lib.mkIf config.custom.games.enable
    {
      # More info on wiki: https://nixos.wiki/wiki/Steam
      programs.steam.enable = true;
      security.polkit.extraConfig = ''
        polkit.addRule(function(action, subject) {
          if (action.id === "org.freedesktop.NetworkManager.settings.modify.system") {
            var name = polkit.spawn(["cat", "/proc/" + subject.pid + "/comm"]);
            if (name.includes("steam")) {
              polkit.log("ignoring steam NM prompt");
              return polkit.Result.NO;
            }
          }
        });
      '';

      home-manager.users.pearman.xdg.desktopEntries.steam = {
        name = "Steam";
        exec = "GDK_SCALE=2 steam %U";
        comment = "Application for managing and playing games on Steam";
        icon = "steam";
        terminal = false;
        type = "Application";
        categories = [ "Network" "FileTransfer" "Game" ];
        mimeType = [ "x-scheme-handler/steam" "x-scheme-handler/steamlink" ];
        prefersNonDefaultGPU = true;
      };
    };
}
