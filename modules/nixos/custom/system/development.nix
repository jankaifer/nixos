{ config, lib, pkgs, ... }:

let
  cfg = config.custom.system.development;
in
{
  options.custom.system.development = {
    enable = lib.mkEnableOption "development";
  };

  config = lib.mkIf cfg.enable {
    # Enable compiling on AArch64
    # https://rbf.dev/blog/2020/05/custom-nixos-build-for-raspberry-pis/#nixos-on-a-raspberry-pi
    boot.binfmt.emulatedSystems = [
      "aarch64-linux"
      "armv7l-linux"
    ];

    # These are needed to have multi-char sympols in various editors
    fonts.packages = [
      pkgs.fira-code
      pkgs.fira-code-symbols
    ];

    environment.systemPackages = [
      # Docker
      pkgs.docker
      pkgs.docker-compose

      # Rust
      pkgs.rustup

      # Nix
      pkgs.nixpkgs-fmt
      pkgs.nil
    ];

    # Authenticate docker registery
    age.secrets.docker-config.file = ../../secrets/docker-config.age;
    systemd.services.docker-login = {
      description = "Authenticate docker container registries";
      wantedBy = [ "multi-user.target" ];
      script = ''
        #! ${pkgs.bash}/bin/bash
        source '${config.age.secrets.docker-config.path}'
        echo "$GHCR_TOKEN" | docker login ghcr.io -u USERNAME --password-stdin
      '';
    };

  };
}
