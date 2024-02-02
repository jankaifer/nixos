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
    impermanence.url = "github:nix-community/impermanence";
    fckKeyboardLayout = {
      flake = false;
      url = "gitlab:JanKaifer/fck";
    };
    myPublicSshKeys = {
      flake = false;
      url = "https://github.com/jankaifer.keys";
    };
    libreChat = {
      flake = false;
      url = "github:danny-avila/LibreChat";
    };
  };

  outputs = { ... }@inputs:
    let
      inherit (inputs.nixpkgs) lib;
      outputs = inputs.self;
      forAllSystems = lib.genAttrs [ "aarch64-linux" "x86_64-linux" ];
    in
    {
      overlays = {
        default = import ./overlay;
        unstable = _: prev: {
          unstable = import inputs.nixpkgs-unstable {
            inherit (prev) system config;
          };
        };
        agenix = inputs.agenix.overlays.default;
      };
      legacyPackages = forAllSystems (system:
        import inputs.nixpkgs {
          inherit system;
          overlays = builtins.attrValues outputs.overlays;
          config.allowUnfree = true;
        }
      );
      homeManagerModules = (import ./modules/home-manager) // {
        impermanence = inputs.impermanence.nixosModules.home-manager.impermanence;
      };
      nixosModules = (import ./modules/nixos) // {
        agenix = inputs.agenix.nixosModules.default;
        home-manager = inputs.home-manager.nixosModules.default;
        impermanence = inputs.impermanence.nixosModules.impermanence;
      };
      nixosConfigurations =
        let
          defaultModules = builtins.attrValues outputs.nixosModules;
          specialArgs = { inherit inputs outputs; };
        in
        {
          "oldbox" = lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              ./machines/oldbox
            ];
          };
          "playground" = lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              ./machines/playground
            ];
          };
          "pearframe" = lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              ./machines/pearframe
            ];
          };
          "pearbox" = lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              ./machines/pearbox
            ];
          };
        };
    };
}
