{
  alsa-lib,
  autoPatchelfHook,
  chromaprint,
  dbus,
  fetchurl,
  gcc,
  glibc,
  stdenv,
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

  src = fetchurl {
    hash = "sha256-jPYlX1Dc8xuYDx8NjcDOX8d7UjSa2x3ig0006+2BQ8Y=";
    url = "https://github.com/M0Rf30/rmpd/releases/download/${version}/rmpd-${version}-x86_64-unknown-linux-gnu.tar.gz";
  };

  version = "0.11.1";
}
