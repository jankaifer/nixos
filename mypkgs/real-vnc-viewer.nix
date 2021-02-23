{ stdenv
, fetchurl
, xorg
, patchelf
, makeWrapper
}:
# Stolen from https://github.com/HanStolpo/nixos-config-public/blob/master/overlays/realvnc-viewer/realvnc-viewer.nix
stdenv.mkDerivation {
  name = "realvnc-viewer";
  src = fetchurl {
    url = "https://www.realvnc.com/download/file/viewer.files/VNC-Viewer-6.20.113-Linux-x64";
    sha256 = "4ac20464566dc6756325bb2476f82f495d7479eb7587f2dd65b3d3f1164d8648";
  };
  dontUnpack = true;
  buildInputs = [ xorg.libX11 xorg.libXext patchelf makeWrapper ];
  buildPhase = ''
    export INTERPRETER=$(cat $NIX_CC/nix-support/dynamic-linker)
    echo "INTERPRETER=$INTERPRETER"
    cp $src realvnc-viewer
    chmod +wx realvnc-viewer
    echo "patching interpreter"
    patchelf --set-interpreter \
      "$INTERPRETER" \
      realvnc-viewer
  '';
  installPhase = ''
    echo "making output directory"
    mkdir -p $out/bin
    echo "copying to output"
    cp realvnc-viewer $out/bin
    echo "wrapping program"
    wrapProgram $out/bin/realvnc-viewer \
      --set LD_LIBRARY_PATH "${xorg.libX11}/lib:${xorg.libXext}/lib"
  '';
}
