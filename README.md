# My system config

This repo tracks my adventures in the reproducible world of nix.

If you are looking trying to get some inspiration for your config, make sure to checkout these:
- https://github.com/dmarcoux/dotfiles-nixos
- https://github.com/DAlperin/dotfiles
- https://github.com/gvolpe/nix-config
- https://github.com/talyz/nixos-config

## Get started
This will clone the whole repo with secrets (private submodule).
```
git clone --recurse-submodules git@gitlab.com:JanKaifer/nixos.git
```

Create unstable chanell:
```
sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos-unstable
```

## Usefull tips

To apply configuration use:
```
sudo nixos-rebuild switch
```

To upgrade channels use:
```
sudo nix-channel --update
```