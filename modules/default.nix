{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./framework.nix
    ./home-manager/nixos
    ./home.nix
    ./impermanence/nixos.nix
    ./real-vnc-viewer
    ./vscode.nix
    ./zsa.nix
  ];
}
