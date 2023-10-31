{ pkgs, ... }:

{
  imports = [
    ./agenix/modules/age.nix
    ./cli-server.nix
    ./cli-workstation.nix
    ./common-workstation.nix
    ./common.nix
    ./fck.nix
    ./framework.nix
    ./games.nix
    ./gui.nix
    ./home-manager/nixos
    ./impermanence.nix
    ./impermanence/nixos.nix
    ./options.nix
    ./real-vnc-viewer
    ./secrets.nix
    ./snapcast.nix
    ./ssh-keys-autogenerate.nix
    ./ssh-server.nix
    ./vscode
    ./wifi-setup.nix
    ./zsa.nix
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.05"; # Did you read the comment?
}
