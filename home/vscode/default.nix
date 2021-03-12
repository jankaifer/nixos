{ pkgs, unstable, toRelativePath, ... }:

with builtins;
{
  enable = false;
  extensions = (with unstable.vscode-extensions; [
    bbenoist.Nix
    coenraads.bracket-pair-colorizer-2
    eamodio.gitlens
    esbenp.prettier-vscode
    formulahendry.auto-rename-tag
    jnoortheen.nix-ide
    jpoissonnier.vscode-styled-components
    ms-python.python
    ms-python.vscode-pylance
    ms-vscode.cpptools
    pkief.material-icon-theme
    streetsidesoftware.code-spell-checker
    vscodevim.vim
    xaver.clang-format
    
    # ms-vscode-remote.remote-ssh
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extra-extensions.nix));
}
