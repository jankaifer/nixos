{
  description = "Jan's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    fckKeyboardLayout = {
      flake = false;
      url = "gitlab:JanKaifer/fck";
    };
  };

  outputs = { self, nixpkgs, agenix, ... }@inputs:
    let
      outputs = self;
    in
    {
      overlays = { };
      nixosModules = import ./modules/nixos;
      nixosConfigurations =
        let
          defaultModules = (builtins.attrValues outputs.nixosModules) ++ [
            agenix.nixosModules.default
            # home-manager.nixosModules.default
          ];
          specialArgs = { inherit inputs outputs; };
        in
        {
          # "oldbox" = nixpkgs.lib.nixosSystem {
          #   inherit specialArgs;
          #   modules = defaultModules ++ [
          #     ./machines/oldbox/configuration.nix
          #   ];
          # };
          "playground" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              ./nixos/playground
            ];
          };
        };
    };
}
