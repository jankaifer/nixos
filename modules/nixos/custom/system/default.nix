{ inputs, outputs, config, lib, pkgs, ... }:

let
  cfg = config.custom.system;
in
{
  imports = [
  ];

  options = { };

  config = {
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    boot.tmp.useTmpfs = lib.mkDefault true;

    time.timeZone = lib.mkDefault "Europe/Prague";
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";

    console = {
      font = lib.mkDefault "ter-i32b";
      packages = [ pkgs.terminus_font ];
      useXkbConfig = lib.mkDefault true;
      earlySetup = lib.mkDefault true;
    };

    services.xserver = {
      layout = lib.mkDefault "fck";
      extraLayouts.fck = {
        description = "fck";
        languages = [ "en" "cs" ];
        symbolsFile = "${inputs.fckKeyboardLayout}/fck";
      };
    };

    nixpkgs.overlays = builtins.attrValues outputs.overlays;
    nixpkgs.config.allowUnfree = true;
    nix = {
      package = pkgs.nix;
      # Makes sure that nix uses the same version for these flakes
      registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
      # Delete old system generations
      gc = {
        automatic = lib.mkDefault true;
        options = lib.mkDefault "--delete-older-than 28d";
        dates = lib.mkDefault "weekly";
      };
      settings = {
        auto-optimise-store = lib.mkDefault true;
        experimental-features = [ "nix-command" "flakes" ];
        # TODO: setup my other machines as substituters to provide binary caches
        # substituters = map (x: substituters.${x}.url) cfg.nix.substituters;
        # trusted-public-keys = map (x: substituters.${x}.key) cfg.nix.substituters;
      };
    };

    services.openssh = with lib; {
      settings.PasswordAuthentication = mkDefault false;
      settings.PermitRootLogin = mkDefault "no";
    };

    environment = {
      systemPackages = [
        inputs.agenix
        pkgs.git
        pkgs.dnsutils
        pkgs.pciutils
      ];
      shells = [ pkgs.zsh ];
      pathsToLink = [ "/share/zsh" ];
    };
  };
}
