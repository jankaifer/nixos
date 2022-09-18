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
  userSettings = { };
}
