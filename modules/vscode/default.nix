{ config, lib, pkgs, ... }:

let
  unstable = import ../nixpkgs-unstable { };
in
{
  options.custom.vscode =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Install vscode with my config.
        '';
      };
    };

  config = lib.mkIf config.custom.vscode.enable {
    home-manager.users.pearman.programs.vscode = {
      enable = true;
      package = pkgs.vscode.fhsWithPackages (
        ps: with ps; [
          # Nix
          unstable.nil
          nixpkgs-fmt

          # Rust
          rustup
          zlib
        ]
      );
      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix).extensions;
    };
  };
}
