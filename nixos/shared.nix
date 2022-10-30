{ ... }@args:

with builtins;
rec {
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };

  toRelativePath = relativePath: toPath (../. + "/${relativePath}");

  # My secrets are living in different repository that is not public:
  # - https://gitlab.com/JanKaifer/nixos-secrets
  secrets = import ../secrets args;

  mypkgs = import (toRelativePath "mypkgs") args;
}
