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
  pname = "falcon-sensor";
  arch = "amd64";
  # You need to get the binary from #it guys
  src = ./falcon-sensor.deb;
  falcon-sensor = stdenv.mkDerivation {
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
    ln -s ${falcon-sensor}/* $out/                                                                                                                                                                                                                                                                    
  '';

  runScript = "bash";
}
