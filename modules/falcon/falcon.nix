{ stdenv
, lib
, pkgs
, dpkg
, openssl
, libnl
, zlib
, fetchurl
, autoPatchelfHook
, buildFHSUserEnv
, writeScript
, ...
}:
let
  pname = "falcon";
  arch = "amd64";
  src = ./falcon.deb;
  falcon = stdenv.mkDerivation {
    inherit arch src;
    name = pname;

    buildInputs = [ dpkg zlib autoPatchelfHook ];

    sourceRoot = ".";

    unpackPhase = ''                                                                                                                                                                                                                                                                                  
      dpkg-deb -x $src .                                                                                                                                                                                                                                                                            
    '';

    installPhase = ''                                                                                                                                                                                                                                                                                 
      cp -r . $out                                                                                                                                                                                                                                                                                  
    '';

    meta = with lib; {
      description = "Crowdstrike Falcon Sensor";
      homepage = "https://www.crowdstrike.com/";
      license = licenses.unfree;
      platforms = platforms.linux;
    };
  };
in
buildFHSUserEnv {
  name = "fs-bash";
  targetPkgs = pkgs: [ libnl openssl zlib ];

  extraInstallCommands = ''                                                                                                                                                                                                                                                                           
    ln -s ${falcon}/* $out/                                                                                                                                                                                                                                                                    
  '';

  runScript = "bash";
}
