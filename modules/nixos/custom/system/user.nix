{ inputs, outputs, config, options, lib, pkgs, ... }:

let
  cfg = config.custom.system;
  # This options is available only in VMs
  isVm = options ? virtualisation.memorySize;
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
      extraSpecialArgs = { inherit inputs outputs; };
      sharedModules = builtins.attrValues outputs.homeManagerModules;
      users.${cfg.user} = import cfg.home-manager.home;
    };
    users = {
      mutableUsers = false;
      defaultUserShell = pkgs.zsh;
      users.${cfg.user} = lib.mkMerge [
        (if isVm then {
          password = "pass";
        } else {
          hashedPasswordFile = config.age.secrets.login-password.path;
        })
        {
          isNormalUser = true;
          extraGroups = [ "wheel" "networkmanager" "docker" ];
          openssh.authorizedKeys.keys = lib.splitString "\n" (builtins.readFile inputs.myPublicSshKeys);
        }
      ];
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
