#!/usr/bin/env bash

set -euo pipefail

# Run this script inside a contabo recovery system and it will bootstrap new NixOS server on you VPS
# Make sure that you bootstrapped your VPS with ubuntu 22.05.
# Run this script with:
# curl https://raw.githubusercontent.com/JanKaifer/nixos/main/scripts/install-on-contabo.sh | $SHELL

###############################
# Setup disk for installation #
###############################

DISK="/dev/sda"
echo "Setting up installation on disk $DISK"
parted "$DISK" print list
echo

echo "Removing old partitions"
for i in {1..5}
do
  echo "Trying to remove ${DISK}${i}"
  umount "${DISK}${i}" || true # can fail
  parted "$DISK" rm "$i" || true # can fail
  echo
done

echo "Creating boot partition"
parted "$DISK" mkpart primary ext4 1049kB 1000MB
parted "$DISK" set 1 bios_grub on
sleep 1
mkfs.fat "${DISK}1"
echo

echo "Creating data partition"
parted "$DISK" mkpart primary ext4 1000MB "100%"
sleep 1
mkfs.btrfs "${DISK}2" -f
echo

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
mkdir -p /nix
mount -o subvol=nix,compress=zstd,noatime "$DISK"2 /nix

# Mount file for ne NixOS system
mkdir -p /mnt
# mount -t tmpfs none /mnt # for using tmpfs
mount -o subvol=root,compress=zstd,noatime "$DISK"2 /mnt # for persistent root

mkdir -p /mnt/nix
mount -o subvol=nix,compress=zstd,noatime "$DISK"2 /mnt/nix

mkdir -p /mnt/persist
mount -o subvol=persist,compress=zstd,noatime "$DISK"2 /mnt/persist

mkdir -p /mnt/var/log
mount -o subvol=log,compress=zstd,noatime "$DISK"2 /mnt/var/log

mkdir -p /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi

mkdir -p /boot/efi
mount /dev/sda1 /boot/efi

# Create symlinks for persisted files
mkdir -p /mnt/etc/
mkdir -p /mnt/persist/etc/nixos
ln -s /mnt/persist/etc/nixos /mnt/etc/nixos

###############
# Install nix #
###############

# create users used by nix
groupadd nixbld -f
for n in $(seq 1 10)
do
  useradd -c "Nix build user $n" -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(command -v nologin)" "nixbld$n" || true # can fail
done

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
git clone --depth=1 --recurse-submodules --shallow-submodules https://github.com/JanKaifer/nixos.git /mnt/persist/home/pearman/dev/jankaifer/nixos
echo

echo "Create hardware-configuration.nix"
nixos-generate-config --root /mnt --show-hardware-config > /mnt/persist/home/pearman/dev/jankaifer/nixos/machines/pearcloud/hardware-configuration.nix
echo

echo "Create configuration.nix"
cat > /mnt/etc/nixos/configuration.nix <<- "EOF"
{...}:
{
  imports = [
    ../../persist/home/pearman/dev/jankaifer/nixos/machines/pearcloud/configuration.nix
  ];
}
EOF
echo

echo "Installing NIXOS"
nixos-install
echo