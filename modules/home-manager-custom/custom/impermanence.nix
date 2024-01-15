{ config, lib, ... }:

let
  cfg = config.custom.cli;
in
{
  options.custom.impermanence = {
    enable = lib.mkEnableOption "impermanence";
    nixosRepoPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos";
      description = "Path the this nixos config repo";
    };
  };

  config = lib.mkIf cfg.enable {
    # Files that we want to track in git
    home.persistence."${cfg.nixosRepoPath}/dotfiles" = {
      removePrefixDirectory = true;
      allowOther = true;
      directories = [ ];
      files = [
        "hyper/.config/hyper/.hyper.js"
        "vscode/.config/Code/User/settings.json"
        "vscode/.config/Code/User/keybindings.json"
      ];
    };
  };
}
 