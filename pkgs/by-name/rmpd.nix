{
  autoPatchelfHook,
  alsa-lib,
  chromaprint,
  dbus,
  fetchurl,
  gcc,
  glibc,
  stdenv,
}:

stdenv.mkDerivation rec {
  pname = "rmpd";
  version = "0.11.1";

  src = fetchurl {
    url = "https://github.com/M0Rf30/rmpd/releases/download/${version}/rmpd-${version}-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-jPYlX1Dc8xuYDx8NjcDOX8d7UjSa2x3ig0006+2BQ8Y=";
  };

  sourceRoot = ".";
  nativeBuildInputs = [ autoPatchelfHook ];
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
}
