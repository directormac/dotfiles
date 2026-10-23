{
  alsa-lib,
  autoPatchelfHook,
  chromaprint,
  dbus,
  fetchurl,
  gcc,
  glibc,
  stdenv,
  rmpd-bin ? null,
}:

stdenv.mkDerivation rec {
  buildInputs = [
    alsa-lib
    chromaprint
    gcc.cc.lib
    glibc
    dbus
  ];

  installPhase = ''
    mkdir -p $out/bin
    cp rmpd $out/bin/
    chmod +x $out/bin/rmpd
  '';

  nativeBuildInputs = [ autoPatchelfHook ];
  pname = "rmpd";
  sourceRoot = ".";

  src =
    if rmpd-bin != null then
      rmpd-bin
    else
      fetchurl {
        hash = "sha256-QzP2zSNDp+ciii6wMZROaMGO14cRCByjEQ1hOekvMDk=";
        url = "https://github.com/M0Rf30/rmpd/releases/download/${version}/rmpd-${version}-x86_64-unknown-linux-gnu.tar.gz";
      };

  version = "0.18.0";
}
