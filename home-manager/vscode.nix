{ pkgs, toRelativePath, unstable, ... }@rest:

{
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
    "vim.useSystemClipboard" = true;
    "workbench.startupEditor" = "none";
  };
}
