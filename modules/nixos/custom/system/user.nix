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
    age.secrets.login-password.file = ../../../../secrets/login-password.age;

    home-manager = lib.mkIf cfg.home-manager.enable {
      useGlobalPkgs = lib.mkDefault true;
      useUserPackages = lib.mkDefault true;
      extraSpecialArgs = { inherit inputs outputs; };
      sharedModules = builtins.attrValues outputs.homeManagerModules;
      users.${cfg.user} = import cfg.home-manager.home;
      # When there is conflict with existing files, HM now creates a backup of that file and force overwrite
      backupFileExtension = "home-manager-backup";
    };


    virtualisation.vmVariant = {
      # In VM we can't access secrets so we need to set password here explicitely
      users.users.${cfg.user}.password = "pass";
    };

    users = {
      mutableUsers = false;
      defaultUserShell = pkgs.zsh;
      users.${cfg.user} = {
        isNormalUser = true;
        hashedPasswordFile = config.age.secrets.login-password.path;
        extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" ];
        openssh.authorizedKeys.keys =
          (lib.splitString "\n" (builtins.readFile inputs.myPublicSshKeys))
          ++
          [ "SHA256:Das4erPF6/vtMtbjv178tG+PWwIHVamoFoDk6gcJHS0 root@coolify" ];
      };
    };
    age.identityPaths = [
      "/home/${cfg.user}/.ssh/id_ed25519"
      "/persist/home/${cfg.user}/.ssh/id_ed25519"
    ];
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


