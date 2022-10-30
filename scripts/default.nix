{ ... }@args:

let
  pkgs = args.pkgs;
  shared = import ../nixos/shared.nix args;

  # Few utils for easier creation of my own scripts
  makeExecutable = name: path: pkgs.writeScriptBin name (builtins.readFile (shared.toRelativePath path));
  makeScript = name: makeExecutable name "scripts/${name}.sh";
in
{
  environment.systemPackages =
    [
      (makeScript "demo-script")
      # (makeScript "lock")
      # (makeScript "reload-polybar")
      # (makeScript "reload-monitors")
    ];
}
