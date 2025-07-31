{
  description = "Jan's NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-grafana-loki.url = "github:NixOS/nixpkgs/e89cf1c932006531f454de7d652163a9a5c86668";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
    myPublicSshKeys = (import ./myPublicSshKeys.nix);
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
        loki = (_: prev: {
          # Loki 3.0 does not work with nix configuration well, it throws this
          ## failed parsing config: /nix/store/xigv76bvgcakdnbzmcdk65ddbharbkym-loki-config.json: yaml: unmarshal errors:
          ##   line 4: field max_look_back_period not found in type config.ChunkStoreConfig
          ##   line 24: field max_transfer_retries not found in type ingester.Config. Use `-config.expand-env=true` flag if you want to expand environment variables in your config file
          grafana-loki = inputs.nixpkgs-grafana-loki.legacyPackages.${prev.system}.grafana-loki;
        });
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
          "hydrogen" = lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              ./machines/hydrogen
            ];
          };

          "iso" = lib.nixosSystem {
            inherit specialArgs;
            modules = defaultModules ++ [
              "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
              ./machines/iso
            ];
          };
        };
    };
}
