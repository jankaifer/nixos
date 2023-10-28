{ config, lib, pkgs, ... }:

{
  options.custom.cli-workstation =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Set's up shell and install basic CLI tools I need on workstation.
        '';
      };
    };

  config = lib.mkIf config.custom.cli-workstation.enable {
    custom.cli-server.enable = true;

    environment.systemPackages = [
      pkgs.bitwarden-cli
      pkgs.cryptsetup
      pkgs.direnv
      pkgs.exercism
      pkgs.fnm
      pkgs.gcc
      pkgs.gh
      pkgs.gnumake
      pkgs.iw
      pkgs.libnotify
      pkgs.mullvad
      pkgs.niv
      pkgs.nixos-generators
      pkgs.steam-run
    ];
  };
}
