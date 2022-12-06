{ config, lib, pkgs, ... }:

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
      package = pkgs.vscode.fhsWithPackages (
        ps: with ps; [
          # General
          git

          # Nix
          nixpkgs-fmt

          # Rust
          rustup
          zlib

          # JS
          fnm

          # These two need to be installed through nix for some reason - they are needed for next.js development
          nodejs-16_x
          nodePackages.yarn
          nodePackages.pnpm
        ]
      );
      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix).extensions;
      userSettings =
        {
          "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
          "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.formatOnSave" = true;
          "editor.minimap.enabled" = false;
          "editor.renderWhitespace" = "all";
          "explorer.confirmDelete" = false;
          "explorer.confirmDragAndDrop" = false;
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.enableSmartCommit" = true;
          "jest.autoRun" = "off";
          "keyboard.dispatch" = "keyCode";
          "projectManager.git.baseFolders" = [
            "/home/pearman/Projects"
            "/home/pearman/dev"
          ];
          "projectManager.git.maxDepthRecursion" = 2;
          "projectManager.showParentFolderInfoOnDuplicates" = true;
          "update.mode" = "none";
          "vim.useSystemClipboard" = true;
          "vim.vimrc.enable" = true;
          "vim.vimrc.path" = "/home/pearman/.vimrc";
          "window.zoomLevel" = 0;
          "workbench.startupEditor" = "none";
        };
    };
  };
}
