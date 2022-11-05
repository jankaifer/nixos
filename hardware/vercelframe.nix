{ pkgs, ... }:

{
  imports = [
    ./common.nix
    ./framework.nix
  ];

  ## Make sure that /var/log is moun ted early enough
  fileSystems."/var/log".neededForBoot = true;

  ## Host name
  networking.hostName = "vercelframe";
}
