{ ... }:

{
  imports = [
    # 3rd party modules
    ./agenix/modules/age.nix
    ./home-manager/nixos
    ./impermanence/nixos.nix
    # my stuff
    ./custom/common.nix
    ./utils.nix
  ];
}
