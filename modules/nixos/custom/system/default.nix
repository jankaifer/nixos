{ inputs, outputs, config, lib, pkgs, ... }:

let
  cfg = config.custom.system;
in
{
  imports = [
    ./gui.nix
    ./user.nix
  ];

  options = { };

  config = {
    hardware.enableRedistributableFirmware = lib.mkDefault true;

    boot.tmp.useTmpfs = lib.mkDefault true;

    time.timeZone = lib.mkDefault "Europe/Prague";
    i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
    i18n.extraLocaleSettings = lib.mkDefault {
      LC_ADDRESS = "cs_CZ.utf8";
      LC_IDENTIFICATION = "cs_CZ.utf8";
      LC_MEASUREMENT = "cs_CZ.utf8";
      LC_MONETARY = "cs_CZ.utf8";
      LC_NAME = "cs_CZ.utf8";
      LC_NUMERIC = "cs_CZ.utf8";
      LC_PAPER = "cs_CZ.utf8";
      LC_TELEPHONE = "cs_CZ.utf8";
      LC_TIME = "cs_CZ.utf8";
    };

    console = {
      font = lib.mkDefault "ter-i32b";
      packages = [ pkgs.terminus_font ];
      useXkbConfig = lib.mkDefault true;
      earlySetup = lib.mkDefault true;
    };

    # Make sude timeout longer
    security.sudo.extraConfig = ''
      Defaults        timestamp_timeout=15
    '';

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

    services.openssh.settings = {
      PasswordAuthentication = lib.mkDefault false;
      PubkeyAuthentication = lib.mkDefault true;
      PermitRootLogin = lib.mkDefault "no";
    };

    environment = {
      systemPackages = [
        pkgs.agenix
        pkgs.git
        pkgs.dnsutils
        pkgs.pciutils
      ];
      shells = [ pkgs.zsh ];
      pathsToLink = [ "/share/zsh" ];
    };
  };
}
