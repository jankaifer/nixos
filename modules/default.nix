{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./framework.nix
    ./gui.nix
    ./home-manager/nixos
    ./impermanence/nixos.nix
    ./iso.nix
    ./keyboard.nix
    ./real-vnc-viewer
    ./vscode.nix
    ./erase-root.nix
    ./zsa.nix
  ];
}
