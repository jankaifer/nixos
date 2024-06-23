# Custom bootable iso

Just run this to get it:

```
nix build .#nixosConfigurations.iso.config.system.build.isoImage
```
