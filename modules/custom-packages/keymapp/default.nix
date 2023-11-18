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
, writeShellScript
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

  installPhase =
    let
      bashWrapper = writeShellScript pname ''
        # This patch is needed when using nvidia GPU https://github.com/NixOS/nixpkgs/issues/266113#issuecomment-1817478988
        export __NV_PRIME_RENDER_OFFLOAD=1 
        exec @out@/opt/${pname}_bin "$@"
      '';
    in
    ''
      runHook preInstall

      mkdir -p $out/share/applications
      mkdir -p $out/opt
      mkdir -p $out/bin

      install -m755 -D keymapp $out/opt/${pname}_bin
      substitute ${bashWrapper} $out/bin/${pname} --subst-var out
      substitute ${./keymapp.desktop} $out/share/applications/${pname}.desktop --subst-var out

      chmod 755 $out/bin/*

      runHook postInstall
    '';

  meta = with lib; {
    homepage = "https://www.zsa.io/flash/";
    description = "ZSA keyboard configuration app";
    platforms = platforms.linux;
  };
}
