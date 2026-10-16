{
  fetchFromGitHub,
  stdenv,
  zsh-histdb-src ? null,
}:
stdenv.mkDerivation rec {
  dontBuild = true;
  dontConfigure = true;

  installPhase = ''
    mkdir -p $out/share/zsh-histdb
    cp -r * $out/share/zsh-histdb/
  '';

  pname = "zsh-histdb";

  src =
    if zsh-histdb-src != null then
      zsh-histdb-src
    else
      fetchFromGitHub {
        owner = "larkery";
        repo = "zsh-histdb";
        rev = version;
        sha256 = "sha256-PQIFF8kz+baqmZWiSr+wc4EleZ/KD8Y+lxW2NT35/bg=";
      };

  strictDeps = true;
  version =
    if zsh-histdb-src != null then
      "0-unstable-${zsh-histdb-src.lastModifiedDate or "latest"}"
    else
      "30797f0c50c31c8d8de32386970c5d480e5ab35d";
}
