{ config, lib, pkgs, ... }:

{
  options.custom.fck =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Use Fancy Czech Keyboard
        '';
      };
    };

  config =
    lib.mkIf config.custom.fck.enable
      {
        console =
          {
            useXkbConfig = true;
            earlySetup = true;
          };

        services.xserver = {
          layout = "fck";
          extraLayouts.fck = {
            description = "Fancy czech keyboard";
            languages = [ "en" "cs" ];
            symbolsFile =
              let
                commit = "365095d7d5c9d912b1945ddd1039f787dc72d186";
              in
              builtins.fetchurl {
                url = "https://gitlab.com/JanKaifer/fck/-/raw/${commit}/fck";
              };
          };
        };
      };
}
