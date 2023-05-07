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
          rust-analyzer

          zlib

          # JS
          fnm
        ]
      );
      extensions = pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extensions.nix).extensions;
      userSettings =
        {
          "[html]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[javascriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[jsonc]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[markdown]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
          "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "[typescriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          "cSpell.language" = "en,cs";
          "editor.formatOnSave" = true;
          "editor.inlineSuggest.enabled" = true;
          "editor.minimap.enabled" = false;
          "editor.renderWhitespace" = "all";
          "editor.tokenColorCustomizations"."textMateRules" = [{ "scope" = "keyword.other.dotenv"; "settings" = { "foreground" = "#FF000000"; }; }];
          "explorer.confirmDelete" = false;
          "explorer.confirmDragAndDrop" = false;
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "git.enableSmartCommit" = true;
          "githubPullRequests.createOnPublishBranch" = "never";
          "grammarly.files.include" = [ "**/*.md" "**/*.txt" ];
          "javascript.inlayHints.enumMemberValues.enabled" = false;
          "javascript.inlayHints.functionLikeReturnTypes.enabled" = false;
          "javascript.inlayHints.parameterNames.enabled" = "all";
          "javascript.inlayHints.parameterNames.suppressWhenArgumentMatchesName" = true;
          "javascript.inlayHints.parameterTypes.enabled" = false;
          "javascript.inlayHints.propertyDeclarationTypes.enabled" = false;
          "javascript.inlayHints.variableTypes.enabled" = true;
          "javascript.updateImportsOnFileMove.enabled" = "always";
          "jest.autoRun" = "off";
          "keyboard.dispatch" = "keyCode";
          "projectManager.git.baseFolders" = [ "/home/pearman/Projects" "/home/pearman/dev" ];
          "projectManager.git.maxDepthRecursion" = 2;
          "projectManager.showParentFolderInfoOnDuplicates" = true;
          "typescript.inlayHints.enumMemberValues.enabled" = false;
          "typescript.inlayHints.functionLikeReturnTypes.enabled" = false;
          "typescript.inlayHints.parameterNames.enabled" = "all";
          "typescript.inlayHints.parameterNames.suppressWhenArgumentMatchesName" = true;
          "typescript.inlayHints.parameterTypes.enabled" = false;
          "typescript.inlayHints.propertyDeclarationTypes.enabled" = false;
          "typescript.inlayHints.variableTypes.enabled" = true;
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
