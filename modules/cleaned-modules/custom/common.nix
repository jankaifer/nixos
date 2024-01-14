{ lib, ... }@params: lib.custom.customModule
{
  params = params;
  name = "common";
  description = "Commont configuration that configs should use. Configures nix, nixpkgs and the rebuild-process.";
  extraOptions = {
    nixosRepoPath = {
      type = lib.types.path;
      default = "/this/path/needs/to/be/set";
      description = ''
        Path where is this repo stored. Probably somewhere in /persist
      '';
    };
    machineName = {
      type = lib.types.str;
      default = "unspecified-machine";
    };
  };
  getConfig = { cfg }: {
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    nixpkgs.config.allowUnfree = true;

    nix.nixPath = [
      "nixpkgs=${cfg.nixosRepoPath}/modules/nixpkgs"
      "nixos-config=${cfg.nixosRepoPath}/machines/${cfg.machineName}/configuration.nix"
    ];

    # Link /etc/nixos to this repo
    environment.etc.nixos = {
      enable = true;
      source = cfg.nixosRepoPath;
      target = "nixos";
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "22.05";
  };
}
