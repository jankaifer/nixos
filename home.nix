{ pkgs, ... }:
let
  configsFolder = "/etc/nixos/configs";
in
with builtins;
{
  nixpkgs.config = {
    allowUnfree = true;
  };

  home.packages = with pkgs; [
    firefox
    google-chrome
    gitkraken
    zoom-us
    discord
    slack-dark
    vscode
    vlc
    kitty
  ];

  programs.git = {
    enable = true;
    userName = "Jan Kaifer";
    userEmail = "jan@kaifer.cz";
  };

  programs.autorandr = {
    enable = true;
    profiles =
      let
        c9 = "00ffffffffffff0009e5210800000000011c0104b51f117803f170aa5445a9240f50540000000101010101010101010101010101010150d000a0f0703e803020350035ae1000001a00000000000000000000000000000000001a000000fe00424f452048460a202020202020000000fe004e5631343051554d2d4e35340a014a02030f00e3058000e60605016a6a24000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009a";
        thinkVision = "00ffffffffffff0030aeb0614656305a1a1d0104b53c22783e2215ac5135b6260e5054a10800d1c081c0810081809500a9c0b30001014dd000a0f0703e803020350055502100001aa36600a0f0701f803020350055502100001a000000fd0017501ea03c010a202020202020000000fc004c454e20503237752d31300a2001ed020320f14b010203121113041490051f230907078301000067030c0020003878565e00a0a0a029503020350055502100001ae26800a0a0402e603020360055502100001a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000063";
      in
      {
        "c9" = {
          fingerprint = {
            eDP-1 = c9;
          };
          config = {
            eDP-1 = {
              enable = true;
              primary = true;
              position = "0x0";
              scale = {
                x = .5;
                y = .5;
              };
              mode = "3840x2160";
              rate = "60.00";
            };
          };
        };
      } // {
        "c9-home" = {
          fingerprint = {
            eDP-1 = c9;
            DP-2 = thinkVision;
          };
          config = {
            eDP-1 = {
              enable = true;
              primary = false;
              scale = {
                x = .5;
                y = .5;
              };
              position = "960x2160";
              mode = "3840x2160";
              rate = "60.00";
            };
            DP-2 = {
              enable = true;
              primary = true;
              position = "0x0";
              mode = "3840x2160";
              rate = "60.00";
            };
          };
        };
      };
  };

  xdg.configFile = {
    "kitty/kitty.conf".source = "${configsFolder}/kitty.conf";
  };
}
