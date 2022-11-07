{ config, lib, pkgs, ... }:

let
  unstable = import ../nixpkgs-unstable { };
in
{
  options.custom.vscode =
    {
      enable = lib.mkOption {
        default = false;
        example = true;
        description = ''
          Install vscode with my config.
        '';
      };
    };

  config = lib.mkIf config.custom.vscode.enable {
    home-manager.users.pearman.programs.vscode = {
      enable = true;
      package = unstable.vscode.fhsWithPackages (
        ps: with ps; [
          # Nix
          unstable.nil
          nixpkgs-fmt

          # Rust
          rustup
          zlib
        ]
      );
      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix).extensions;
      userSettings = {
        "editor.minimap.enabled" = false;
        "git.enableSmartCommit" = true;
        "git.autofetch" = true;
        "git.confirmSync" = false;
        "explorer.confirmDelete" = false;
        "explorer.confirmDragAndDrop" = false;
        "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
        # Nil is broken in my setup :sad:
        # "nix.enableLanguageServer" = true;
        # "nix.serverPath" = "nil";
        "editor.formatOnSave" = true;
        "window.zoomLevel" = 0;
        "keyboard.dispatch" = "keyCode";
        "vim.vimrc.enable" = true;
        "vim.vimrc.path" = "/home/pearman/.vimrc";
        "vim.useSystemClipboard" = true;
        "workbench.startupEditor" = "none";
        "update.mode" = "none";
        "editor.renderWhitespace" = "all";
        "projectManager.showParentFolderInfoOnDuplicates" = true;
        "projectManager.git.baseFolders" = [
          "/home/pearman/Projects"
        ];
        "projectManager.git.maxDepthRecursion" = 1;
      };
    };
  };
}
