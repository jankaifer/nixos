# My system config

This repo tracks my adventures in the reproducible world of nix.

If you are looking trying to get some inspiration for your config, make sure to checkout these:
- https://github.com/dmarcoux/dotfiles-nixos
- https://github.com/DAlperin/dotfiles
- https://github.com/gvolpe/nix-config
- https://github.com/talyz/nixos-config

Other sources that I used:
- https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html#fn3

## Install on a new machine

To install this config on a new machine, you can use [custom iso](./machines/jankaifer-iso/README.md).

The following guide will install this config on exising nixos machine.

1. Clone this repo with all submodules.
```
git clone --recurse-submodules git@gitlab.com:JanKaifer/nixos.git
```

2. Link this repo to `/etc/nixos`:
```
sudo mv /etc/nixos/ /etc/nixos-old
sudo mkdir /etc/nixos
sudo ln -s /home/pearman/Projects/nixos /etc/nixos
```

3. Create password file in root of this repo.
```
mkpasswd -m sha-512 > /etc/nixos/passwordFile
```

4. Before first build you need to choose the correct configuration file by providing hostname of that machine (look at [machines](./machines) for list of all possible configurations):
```
sudo /etc/nixos/scripts/rebuild.sh --hostname "pearframe" switch
```

## Usefull tips

To apply configuration use:
```
sudo /etc/nixos/scripts/rebuild.sh switch
```

Watch changes in dconf with:
```
dconf watch /
```