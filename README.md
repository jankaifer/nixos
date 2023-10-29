# My system config

This repo tracks my adventures in the reproducible world of nix.

If you are looking for some inspiration for your config, make sure to check these:

- https://github.com/dmarcoux/dotfiles-nixos
- https://github.com/DAlperin/dotfiles
- https://github.com/gvolpe/nix-config
- https://github.com/talyz/nixos-config

Other sources that I used:

- https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html#fn3

## Install on a new machine

To install this config on a new machine, you can use [custom iso](./machines/jankaifer-iso/README.md).

The following guide will install this config on an existing nixos machine.

1. Clone this repo with all submodules.

```
git clone --recurse-submodules git@gitlab.com:JanKaifer/nixos.git
```

2. Link this repo to `/etc/nixos`:

```
sudo mv /etc/nixos/ /etc/nixos-old
sudo mkdir /etc/nixos
sudo ln -s /persist/home/pearman/dev/jankaifer/nixos /etc/nixos
```

3. Create a password file in the root of this repo.

```
mkpasswd -m sha-512 > /etc/nixos/passwordFile
```

4. Before the first build you need to choose the correct configuration file by providing a hostname of that machine (look at [machines](./machines) for a list of all possible configurations):

```
sudo /etc/nixos/scripts/rebuild.sh --hostname "pearframe" switch
```

## Usefultips

To apply configuration use:

```
sudo /etc/nixos/scripts/rebuild.sh switch
```

Watch changes in dconf with:

```
dconf watch /
```

## Secrets management

I'm using agenix to save my secrets into this public config.

To set an updated login password, you just need to run the following:

```
cd secrets
mkpasswd -m sha-512 | agenix -e password-file.age
```

## Create raspberry pi minimal iso

It's easy to create new image files for raspberry with my custom minimal config. They contain my wifi passwords with running openssh daemon out of the box.

To create the image, just run:

```
nixos-generate -f sd-aarch64-installer --system aarch64-linux -c /etc/nixos/machines/minimal-raspberry-config/configuration.nix -I nixpkgs=/etc/nixos/modules/nixpkgs
```

It prints some nix store path where you can find the final image file. You can flash that using `etcher` on an sd card.

## Deploy to remote machine

It's easy to deploy configuration to remote machine, just use the following command (and tweak target machine and configuration deployed):

```
NIXOS_CONFIG=/etc/nixos/machines/minimal-raspberry-config/configuration.nix nixos-rebuild build --target-host nixos@192.168.88.30 --use-remote-sudo
```
