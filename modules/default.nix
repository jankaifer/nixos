{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./framework.nix
    ./gui.nix
    ./home-manager/nixos
    ./home.nix
    ./impermanence/nixos.nix
    ./non-iso.nix
    ./real-vnc-viewer
    ./vscode.nix
    ./zsa.nix
  ];
}
