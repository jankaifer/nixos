{ stdenv
, lib
, fetchurl
, autoPatchelfHook
}:
let
  version = "6.20.529";
  binaryName = "VNC-Viewer-${version}-Linux-x64";
in
stdenv.mkDerivation rec {
  name = "real-vnc-viewer-${version}";
  inherit version;

  src = fetchurl {
    url = "https://www.realvnc.com/download/file/viewer.files/${binaryName}";
    sha256 = "3824f25c98d0cb651376d5736c9c93d1437c6842efb09bd8a26c52804ab6b5d3";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [ ];

  unpackPhase = "";

  installPhase = ''
    install -m755 -D "${binaryName}" $out/bin/real-vnc-viewer
  '';

  meta = with lib; {
    homepage = https://realvnc.com;
    description = "Real VNC Viewer";
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
