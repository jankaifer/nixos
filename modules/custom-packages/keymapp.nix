{ stdenv
, lib
, fetchurl
, alsaLib
, openssl
, zlib
, pulseaudio
, autoPatchelfHook
, libusb1
}:

stdenv.mkDerivation rec {
  pname = "keymapp";
  version = "21.07.0";

  src = fetchurl {
    url = "https://oryx.nyc3.cdn.digitaloceanspaces.com/keymapp/keymapp-latest.tar.gz";
    hash = "sha256-e9Ty3gMb+nkXGK8sND4ljyrIxP+1fLasiV6DoTiWmsU=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  buildInputs = [
    libusb1
  ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall
    ls
    install -m755 -D keymapp $out/bin/keymapp
    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://www.zsa.io/flash/";
    description = "ZSA keyboard configuration app";
    platforms = platforms.linux;
  };
}
