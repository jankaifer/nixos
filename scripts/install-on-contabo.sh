#!/usr/bin/env bash

set -euo pipefail

# Run this script inside a contabo recovery system and it will bootstrap new NixOS server on you VPS
# Run this script with:
# curl https://raw.githubusercontent.com/JanKaifer/nixos/main/scripts/install-on-contabo.sh | sh

###############################
# Setup disk for installation #
###############################

DISK="/dev/sda"
echo "Setting up installation on disk $DISK"
parted "$DISK" print list

echo "Removing old partitions"
parted "$DISK" rm 2
parted "$DISK" rm 1

echo "Creating boot partition"
parted "$DISK" mkpart primary ext4 1049kB 1000MB
parted "$DISK" set 1 boot on
mkfs.ext4 "${DISK}1" -f

echo "Creating data partition"
parted "$DISK" mkpart primary ext4 1000MB "100%"
mkfs.brtfs "${DISK}2" -f

echo "Creating btrfs volumes"
mount "$DISK"2 /mnt

btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/nix
btrfs subvolume create /mnt/persist
btrfs subvolume create /mnt/log

umount /mnt

###############
# Mount stuff #
###############

# Mount /nix to recovery OS
mkdir /nix
mount -o subvol=nix,compress=zstd,noatime /dev/mapper/enc /nix

# Mount file for ne NixOS system
mkdir -p /mnt
# mount -t tmpfs none /mnt # for using tmpfs
mount -o subvol=root,compress=zstd,noatime /dev/sda2 /mnt # for persistent root

mkdir -p /mnt/nix
mount -o subvol=nix,compress=zstd,noatime /dev/sda2 /mnt/nix

mkdir -p /mnt/persist
mount -o subvol=persist,compress=zstd,noatime /dev/sda2 /mnt/persist

mkdir -p /mnt/var/log
mount -o subvol=log,compress=zstd,noatime /dev/sda2 /mnt/var/log

mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot

# Create symlinks for persisted files
mkdir -p /mnt/etc
ln -s /mnt/persist/etc/nixos /mnt/etc/nixos

###############
# Install nix #
###############

# create users used by nix
groupadd nixbld
for n in $(seq 1 10); do useradd -c "Nix build user $n" -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(command -v nologin)" "nixbld$n"; done

# install nix itself
bash <(curl -L https://nixos.org/nix/install)
. $HOME/.nix-profile/etc/profile.d/nix.sh
nix-channel --add https://nixos.org/channels/nixos-22.11 nixpkgs

# install installation tools with nix
nix-env -iE "_: with import <nixpkgs/nixos> { configuration = {}; }; with config.system.build; [ nixos-generate-config nixos-install nixos-enter manual.manpages ]"

###########
# Install #
###########

echo "Clone my configuration"
mkdir -p /mnt/persist/home/pearman/dev/jankaifer/
git clone --recurse-submodules --shallow-submodules git@gitlab.com:JanKaifer/nixos.git /mnt/persist/home/pearman/dev/jankaifer/nixos

echo "Create hardware-configuration.nix"
nixos-generate-config --root /mnt --show-hardware-config > /mnt/etc/nixos/hardware-configuration.nix

echo "Create configuration.nix"
cat > /mnt/etc/nixos/configuration.nix <<- "EOF"
{...}:
{
  imports = [
    ../../persist/home/pearman/dev/jankaifer/nixos/machines/pearcloud/configuration.nix
  ];
}
EOF

nixos-install