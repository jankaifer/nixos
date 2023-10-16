{ pkgs, ... }:

{
  imports = [
    ./agenix/modules/age.nix
    ./common.nix
    ./erase-root.nix
    ./framework.nix
    ./games.nix
    ./gui.nix
    ./home-manager/nixos
    ./impermanence/nixos.nix
    ./iso.nix
    ./keyboard.nix
    ./real-vnc-viewer
    ./secrets.nix
    ./vscode
    ./wifi-setup.nix
    ./zsa.nix
  ];
}
