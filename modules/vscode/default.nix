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
          git-lfs

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
          "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[javascriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[jsonc]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[markdown]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
          "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[typescriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "editor.formatOnSave" = true;
          "editor.inlineSuggest.enabled" = true;
          "editor.minimap.enabled" = false;
          "editor.renderWhitespace" = "all";
          "editor.tokenColorCustomizations"."textMateRules" = [
            {
              "scope" = "keyword.other.dotenv";
              "settings" = {
                "foreground" = "#FF000000";
              };
            }
          ];
          "explorer.confirmDelete" = false;
          "explorer.confirmDragAndDrop" = false;
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.enableSmartCommit" = true;
          "javascript.updateImportsOnFileMove.enabled" = "always";
          "jest.autoRun" = "off";
          "keyboard.dispatch" = "keyCode";
          "projectManager.git.baseFolders" = [
            "/home/pearman/Projects"
            "/home/pearman/dev"
          ];
          "projectManager.git.maxDepthRecursion" = 2;
          "projectManager.showParentFolderInfoOnDuplicates" = true;
          "typescript.updateImportsOnFileMove.enabled" = "always";
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
