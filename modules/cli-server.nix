{ config, lib, pkgs, ... }:

{
  options.custom.cli-server =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Set's up shell and install basic CLI tools I need on server.
        '';
      };
    };

  config = lib.mkIf config.custom.cli-server.enable {
    environment.systemPackages = [
      (pkgs.callPackage ./agenix/pkgs/agenix.nix { })
      pkgs.acpi
      pkgs.binutils
      pkgs.git
      pkgs.htop
      pkgs.killall
      pkgs.lshw
      pkgs.parted
      pkgs.tree
      pkgs.unzip
      pkgs.wget
      pkgs.zsh-you-should-use

      # Nix
      pkgs.nix-output-monitor
      pkgs.nixpkgs-fmt

      # Python
      pkgs.black
      pkgs.python3Full
    ];
  };
}
