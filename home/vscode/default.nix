{ pkgs, unstable, toRelativePath, ... }:

with builtins;
{
  enable = true;
  extensions = (with unstable.vscode-extensions; [
    bbenoist.Nix
    coenraads.bracket-pair-colorizer-2
    eamodio.gitlens
    esbenp.prettier-vscode
    formulahendry.auto-rename-tag
    jnoortheen.nix-ide
    jpoissonnier.vscode-styled-components
    ms-azuretools.vscode-docker
    ms-python.python
    ms-python.vscode-pylance
    ms-vscode-remote.remote-ssh
    ms-vscode.cpptools
    pkief.material-icon-theme
    streetsidesoftware.code-spell-checker
    vscodevim.vim
    xaver.clang-format
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace (import ./extra-extensions.nix));
}
