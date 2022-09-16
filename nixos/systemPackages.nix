{ pkgs, ... }:

let
  pythonVersion = "38";
  pythonFull = pkgs."python${pythonVersion}Full";
  pythonPackages = pkgs."python${pythonVersion}Packages";
  pisek = pkgs."python${pythonVersion}Packages".buildPythonPackage rec {
    name = "pisek";
    version = "0.1";

    src = pkgs.fetchFromGitHub {
      owner = "kasiopea-org";
      repo = "${name}";
      rev = "${version}";
    };
  };
  pythonWithMyPackages = pythonFull.withPackages (pythonPackages: with pythonPackages; [
    pisek
  ]);
in
{
  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs;
    [
      # Basic utils
      wget
      iw
      tree
      lshw
      git
      gnumake
      gcc
      vim
      htop
      zsh-powerlevel10k
      zsh-you-should-use
      acpi
      parted
      direnv
      cryptsetup
      binutils
      killall
      libnotify
      gnome3.gnome-software
      gnome3.gnome-tweaks

      # X server
      xorg.xeyes
      xorg.xhost

      # Nix
      nixpkgs-fmt
      nix-output-monitor

      # Python
      pythonFull
      black
      pythonPackages.ipython

      # Node
      nodejs
      nodePackages.yarn
      nodePackages.npm

      # Docker
      docker

      # Rust
      rustc
      cargo

      # Prolog
      swiProlog

      # My scripts
      # (makeScript "lock")
      # (makeScript "reload-polybar")
      # (makeScript "reload-monitors")
      # (makeScript "run-steam-game")
      # (makeExecutable "nsu-start" "NSU/nsu-start.sh")
      # (makeExecutable "nsu-stop" "NSU/nsu-stop.sh")
      # (makeExecutable "nsu-run" "NSU/nsu-run.sh")
      # (makeExecutable "nsu-save" "NSU/nsu-save.sh")
    ];
}
