{
  description = "Jan's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations = {
      "oldbox" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ./machines/oldbox/configuration.nix
        ];
      };
    };
  };
}
