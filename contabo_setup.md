# installing nix on my contabo VPS

get nix running on recovery image

```bash
# mount /nix
mkdir /nix
mount -o subvol=nix,compress=zstd,noatime /dev/mapper/enc /nix

# create users used by nix
groupadd nixbld
for n in $(seq 1 10); do useradd -c "Nix build user $n" -d /var/empty -g nixbld -G nixbld -M -N -r -s "$(command -v nologin)" "nixbld$n"; done

# install nix itself
bash <(curl -L https://nixos.org/nix/install)
. $HOME/.nix-profile/etc/profile.d/nix.sh
nix-channel --add https://nixos.org/channels/nixos-22.11 nixpkgs

# install installation tools with nix
nix-env -iE "_: with import <nixpkgs/nixos> { configuration = {}; }; with config.system.build; [ nixos-generate-config nixos-install nixos-enter manual.manpages ]"
```

Wire up storage in `/mnt` folder

```bash
# mount files

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

# link useful folders
mkdir -p /mnt/etc
ln -s /mnt/persist/etc/nixos /mnt/etc/nixos
```