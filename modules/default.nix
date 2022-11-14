{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./erase-root.nix
    ./falcon-sensor
    ./framework.nix
    ./games.nix
    ./gui.nix
    ./home-manager/nixos
    ./impermanence/nixos.nix
    ./iso.nix
    ./keyboard.nix
    ./real-vnc-viewer
    ./vscode
    ./work.nix
    ./zsa.nix
  ];
}
