# My system config

This repo tracks my adventures in the reproducible world of nix.

If you are looking for some inspiration for your config, make sure to check these:

- https://github.com/dmarcoux/dotfiles-nixos
- https://github.com/DAlperin/dotfiles
- https://github.com/gvolpe/nix-config
- https://github.com/talyz/nixos-config
- https://github.com/LongerHV/nixos-configuration

Other sources that I used:

- https://mt-caret.github.io/blog/posts/2020-06-29-optin-state.html

> Warning: Documentation can be (and probably is) outdated.
> If something is not clear, then feel free to open new Github issue and I'll try to help you.

## Running machines in VM

With flakes, it's easy to run these configs in a VM.
It won't be able to get secrets from agenix, but otherwise, it should give you an exact copy of the actual system.
It's great for quick iterations.

```bash
# Run this from the root of the repo to run VM of current machine (use `--flake .#machine-name for different machine`)
nixos-rebuild build-vm --flake . && ./result/bin/run-pearframe-vm
```

## To use selected configuration you can install it with

```bash
nixos-rebuild switch --flake .
```

## Install on a new machine

To install this config on a new machine, you can use [custom iso](./machines/jankaifer-iso/README.md).

Most of these steps are from [official wiki](https://nixos.org/manual/nixos/stable/index.html#sec-installation-manual).

### Make partitions

> TODO: describe how to setup encrypted partitions

ISO has `gparted` available, use that to create one `btrfs` partition for system/data and one boot partition. Create these in the following order:

1. ESP partition
   - size: 2048MiB (at the beginning)
   - flags: esp, boot
   - name: boot
   - label: boot
2. Swap partition
   - size: 32768MiB (depending on device RAM, at the very end of disk)
   - flags: linux-swap
   - name: swap
   - label: swap
   - use option `swapon`
3. Main partition
   - size: fill all free space
   - flags: linux-home
   - name: nixos
   - label: nixos

Let's setup btrfs volumes:

```bash
sudo mount -t btrfs /dev/disk/by-label/nixos /mnt

sudo btrfs subvolume create /mnt/persist
sudo btrfs subvolume create /mnt/root
sudo btrfs subvolume create /mnt/nix
sudo btrfs subvolume create /mnt/log

# We then take an empty *readonly* snapshot of the root subvolume,
# which we'll eventually rollback to on every boot.
sudo btrfs subvolume snapshot -r /mnt/root /mnt/root-blank

sudo umount /mnt
```

Now we can mount all partitions as they should be on the new system.

```bash
sudo mount -o subvol=root,noatime /dev/disk/by-label/nixos /mnt

sudo mkdir /mnt/nix
sudo mount -o subvol=nix,compress=zstd:1,noatime /dev/disk/by-label/nixos /mnt/nix

sudo mkdir /mnt/persist
sudo mount -o subvol=persist,compress=zstd:1,noatime /dev/disk/by-label/nixos /mnt/persist

sudo mkdir -p /mnt/var/log
sudo mount -o subvol=log,compress=zstd:3,noatime /dev/disk/by-label/nixos /mnt/var/log

sudo mkdir /mnt/boot
sudo mount /dev/disk/by-label/BOOT /mnt/boot
```

Now let nixos generate hardware config:

```bash
sudo nixos-generate-config --root /mnt
```

Move generated config and use custom config instead:

```bash
sudo mv /mnt/etc/nixos/ /mnt/etc/nixos-old
sudo mkdir -p /mnt/persist/home/jankaifer/dev/jankaifer
cd /mnt/persist/home/jankaifer/dev/jankaifer
sudo git clone --recurse-submodules https://github.com/jankaifer/nixos
cd -
sudo ln -s /mnt/persist/home/jankaifer/dev/jankaifer/nixos /mnt/etc/nixos
```

Create new machine config files in this repo:

```bash
sudo cp /mnt/etc/nixos-old/ /mnt/etc/nixos/machines/machine-name -r
```

You can tweak the configuration now. Make sure that hardware configuration contains all options that we want like compression and `noatime`. Also make sure that logs have `neededForBoot = true;` otherwise boot logs won't be persisted.

In order to properly start the system you need some secrets provided by agenix. For that you need to:
1. create a new ssh key on new machine
2. add it to your github account
3. regenerate agenix secrets on computer with access to the secrets

To generate new ssh key you can use:
```bash
ssh-keygen -t ed25519 -C "jankaifer@machine-name"
```

And now you can install the config via flakes by running this:
```bash
sudo nixos-install --flake /mnt/persist/home/jankaifer/dev/jankaifer/nixos#machine-name
```

---

The following guide will install this config on an existing nixos machine.

4. Clone this repo with all submodules.

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

## Useful tips

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

```bash
rebuild-remote -h raspberry-1
```
