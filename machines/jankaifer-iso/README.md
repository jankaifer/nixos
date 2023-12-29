# How to create bootable ISO

Sources:

- Wiki - https://nixos.wiki/wiki/Creating_a_NixOS_live_CD
- Docs - https://nixos.org/manual/nixos/stable/index.html#sec-building-image

## How to install on a new Machine

```bash
nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=machines/jankaifer-iso/configuration.nix
```
