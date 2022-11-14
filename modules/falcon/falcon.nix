{ pkgs ? import <nixpkgs> { } }:
with pkgs;

stdenv.mkDerivation {
  name = "falcon-sensor";
  version = "4.18.0-6402";
  arch = "amd64";
  src = ./falcon.deb;

  nativeBuildInputs = [ dpkg autoPatchelfHook zlib pkgs.libnl pkgs.openssl ];
  propagateBuildInputs = [ pkgs.libnl pkgs.openssl ];

  sourceRoot = ".";

  unpackCmd = ''
    dpkg-deb -x "$src" .
  '';

  installPhase = ''
    cp -r ./ $out/
    realpath $out
  '';

  meta = {
    description = "Crowdstrike Falcon Sensor";
    homepage = "https://www.crowdstrike.com/";
    license = licenses.unfree;
    platforms = platforms.linux;
  };
}
