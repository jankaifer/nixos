{ pkgs, ... }:
with pkgs;
{
  real-vnc-viewer = callPackage ./real-vnc-viewer.nix { };
}
