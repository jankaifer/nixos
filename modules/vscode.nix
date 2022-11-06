{ pkgs, ... }:

{
  home-manager.users.pearman.programs.vscode = {
    enable = true;
    package = pkgs.vscode.fhsWithPackages (
      ps: with ps; [
        # Rust
        rustup
        zlib
      ]
    );
    extensions = with pkgs.vscode-extensions; [
      dracula-theme.theme-dracula
      vscodevim.vim
      yzhang.markdown-all-in-one
    ];
    userSettings = {
      "editor.minimap.enabled" = false;
      "git.enableSmartCommit" = true;
      "git.autofetch" = true;
      "git.confirmSync" = false;
      "explorer.confirmDelete" = false;
      "explorer.confirmDragAndDrop" = false;
      "[nix]"."editor.defaultFormatter" = "B4dM4n.nixpkgs-fmt";
      "editor.formatOnSave" = true;
      "window.zoomLevel" = 0;
      "keyboard.dispatch" = "keyCode";
      "vim.vimrc.enable" = true;
      "vim.vimrc.path" = "/home/pearman/.vimrc";
      "vim.useSystemClipboard" = true;
      "workbench.startupEditor" = "none";
      "update.mode" = "none";
      "editor.renderWhitespace" = "all";
    };
  };
}