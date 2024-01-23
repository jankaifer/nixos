{ config, lib, pkgs, ... }:

let
  cfg = config.custom.vscode;
in
{
  options.custom.vscode = {
    enable = lib.mkEnableOption "vscode";
  };

  config = lib.mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode.fhsWithPackages (
        ps: [
          # General cli
          ps.git
          ps.git-lfs

          # Nix
          ps.nixpkgs-fmt
          ps.nil

          # Rust
          ps.rustup

          # JS
          ps.fnm

          # Libs
          ps.zlib

          # Docker
          ps.docker
        ]
      );
      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix).extensions;
    };
  };
}
