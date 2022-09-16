{ toRelativePath, pkgs, ... }:

let
  # Few utils for easier creation of my own scripts
  makeExecutable = name: path: pkgs.writeScriptBin name (builtins.readFile (toRelativePath path));
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
