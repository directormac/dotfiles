# Shared derivation for vellum.nvim and vellum-render
{ pkgs }:
let
  vellumSrc = pkgs.fetchFromGitHub {
    hash = "sha256-WKbnohPgZOQd1klxXXDGKbZeMSNQmjEuYTi+sL+zMgA=";
    owner = "zFrenesy";
    repo = "vellum.nvim";
    rev = "910b79e76f5a3389e55a64da9b6816cb9e89a64e";
  };

  vellum-render = pkgs.buildNpmPackage {
    dontNpmBuild = true;
    env.PUPPETEER_SKIP_DOWNLOAD = "true";

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/node_modules/vellum-render
      cp -r node_modules $out/lib/node_modules/vellum-render/node_modules
      runHook postInstall
    '';

    npmDepsHash = "sha256-Zcitez2/UGHu4Reux1XwTBwLMzyMDg17Ywa6QXWGTYQ=";
    npmFlags = [ "--ignore-scripts" ];
    pname = "vellum-render";
    src = "${vellumSrc}/render";
    version = "unstable-2026-10-13";
  };
in
pkgs.vimUtils.buildVimPlugin {
  doCheck = false;
  pname = "vellum.nvim";

  postPatch = ''
    substituteInPlace render/browser.mjs \
      --replace-fail "puppeteer.launch({" "puppeteer.launch({ executablePath: process.env.PUPPETEER_EXECUTABLE_PATH,"
  '';

  postInstall = ''
    cp -r ${vellum-render}/lib/node_modules/vellum-render/node_modules \
      $out/render/node_modules
  '';

  src = vellumSrc;
  version = "unstable-2026-10-13";
}
