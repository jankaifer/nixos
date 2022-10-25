{ pkgs, ... }:

let
  pythonVersion = "38";
  pythonFull = pkgs."python${pythonVersion}Full";
  pythonPackages = pkgs."python${pythonVersion}Packages";
  pisek = pythonPackages.buildPythonPackage rec {
    name = "pisek";
    version = "91147841066e5ff835e9b05653fe46bed989f449";

    src = pkgs.fetchFromGitHub {
      owner = "kasiopea-org";
      repo = "${name}";
      rev = "${version}";
      hash = "sha256-92OzuQhJqKP/27/lbAE/QNAgyNqXONBVQFoJd8ScZBw=";
    };
  };
  pythonWithMyPackages = pythonFull.withPackages (pythonPackages: with pythonPackages; [
    # pisek
    ipython
    pip
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
      gnome.gnome-software
      gnome.gnome-tweaks

      # X server
      xorg.xeyes
      xorg.xhost

      # Nix
      nixpkgs-fmt
      nix-output-monitor

      # Python
      pythonWithMyPackages
      black

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
    ];
}
