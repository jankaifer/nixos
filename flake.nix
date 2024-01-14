{
  description = "Jan's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs:
    let
      outputs = self;
      # nixosModules = import ./modules/nixos;
      nixosModules = { };
    in
    {
      inherit nixosModules;
      nixosConfigurations =
        let
          defaultModules = (builtins.attrValues nixosModules) ++ [
            # home-manager.nixosModules.default
          ];
          specialArgs = { inherit inputs outputs; };
        in
        {
          "oldbox" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              ./machines/oldbox/configuration.nix
            ];
          };
          "playground" = nixpkgs.lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
            ];
          };
        };
    };
}
