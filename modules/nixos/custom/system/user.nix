{ inputs, outputs, config, lib, pkgs, ... }:

let
  cfg = config.custom.system;
in
{
  options.custom.system = {
    user = lib.mkOption {
      default = "jankaifer";
      type = lib.types.str;
    };
    home-manager = {
      enable = lib.mkEnableOption "home-manager";
      home = lib.mkOption {
        default = ../../../../home-manager;
        description = "Path to home manager configuration";
        type = lib.types.path;
      };
    };
  };

  config = {
    home-manager = lib.mkIf cfg.home-manager.enable {
      useGlobalPkgs = lib.mkDefault true;
      useUserPackages = lib.mkDefault true;
      extraSpecialArgs = { inherit inputs; };
      sharedModules = builtins.attrValues outputs.homeManagerModules;
      users.${cfg.user} = import cfg.home-manager.home;
    };
    users = {
      defaultUserShell = pkgs.zsh;
      users.${cfg.user} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" "docker" ];
        openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile inputs.myPublicSshKeys);
      };
    };
    programs.neovim = {
      enable = true;
      defaultEditor = true;
    };
    programs.zsh = {
      enable = true; # Workaround for https://github.com/nix-community/home-manager/issues/2751
      enableCompletion = false;
    };
  };
}
