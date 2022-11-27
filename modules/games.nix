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

      home-manager.users.pearman.xdg.desktopEntries.steam = lib.mkIf config.programs.steam.enable {
        name = "Steam";
        exec = "GDK_SCALE=2 steam";
      };
    };
}
