{ config, lib, pkgs, ... }:

{
  options.custom.basic-cli =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Enables my default shell as login shell and installs basic CLI utils.
        '';
      };
    };

  config = lib.mkIf config.custom.basic-cli.enable
    {
      environment.systemPackages = pkgs.lib.mkMerge
        [
          (pkgs.callPackage ./agenix/pkgs/agenix.nix { })
          pkgs.acpi
          pkgs.binutils
          pkgs.bitwarden-cli
          pkgs.cryptsetup
          pkgs.direnv
          pkgs.exercism
          pkgs.fnm
          pkgs.gcc
          pkgs.gh
          pkgs.git
          pkgs.gnumake
          pkgs.htop
          pkgs.iw
          pkgs.killall
          pkgs.libnotify
          pkgs.lshw
          pkgs.mullvad
          pkgs.niv
          pkgs.nixos-generators
          pkgs.parted
          pkgs.steam-run
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
