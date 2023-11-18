{ stdenv
, lib
, fetchurl
, alsaLib
, openssl
, zlib
, pulseaudio
, autoPatchelfHook
, libusb1
, webkitgtk
, gtk3
}:

stdenv.mkDerivation rec {
  pname = "keymapp";
  version = "1.0.5";

  src = fetchurl {
    url = "https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-${version}.tar.gz";
    hash = "sha256-e9Ty3gMb+nkXGK8sND4ljyrIxP+1fLasiV6DoTiWmsU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    libusb1
    webkitgtk
    gtk3
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    install -m755 -D keymapp $out/bin/keymapp
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://www.zsa.io/flash/";
    description = "ZSA keyboard configuration app";
    platforms = platforms.linux;
  };
}
