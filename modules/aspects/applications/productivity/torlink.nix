# TorLink Aspect
{
  lib,
  inputs,
  ...
}:
let
  torlinkPkg =
    pkgs:
    let
      libdatachannel = pkgs.fetchFromGitHub {
        fetchSubmodules = true;
        hash = "sha256-rr3au3JMqLd/sjNtXtXY2mcuW0CeOgG+Xj2RgEQCWys=";
        owner = "paullouisageneau";
        repo = "libdatachannel";
        tag = "v0.24.5";
      };

      libdatachannelBuildDeps = pkgs.stdenv.mkDerivation {
        buildPhase = ''
          export HOME=$(mktemp -d)
          export SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
          cp ${inputs.torlink}/nix/package.json package.json
          cp ${inputs.torlink}/nix/package-lock.json package-lock.json
          npm ci --ignore-scripts
          mkdir -p $out
          cp -r node_modules $out/
        '';

        dontInstall = true;
        dontUnpack = true;
        name = "libdatachannel-build-deps";

        nativeBuildInputs = [
          pkgs.nodejs_22
          pkgs.cacert
        ];

        outputHash = "sha256-Psa2R99JFUHGCA3DsrKFYgC1D7KIY+Va/kDGuiRi/CQ=";
        outputHashMode = "recursive";
      };
    in
    pkgs.buildNpmPackage {
      __structuredAttrs = true;
      buildInputs = [ pkgs.openssl ];
      dontUseCmakeConfigure = true;
      nativeBuildInputs = [ pkgs.cmake ];
      nodejs = pkgs.nodejs_22;
      npmDepsHash = "sha256-ff51LO8a87Y3VI38J2TLEIcIOkohr81OTGpBp7UO3Nc=";
      npmFlags = [ "--ignore-scripts" ];
      pname = "torlink";

      postBuild = ''
        node scripts/postbuild.cjs
      '';

      postInstall = ''
        pushd $out/lib/node_modules/torlnk-rd/node_modules/node-datachannel || pushd $out/lib/node_modules/torlnk/node_modules/node-datachannel

        substituteInPlace CMakeLists.txt \
          --replace-fail \
          'set(OPENSSL_USE_STATIC_LIBS TRUE)' \
          'set(OPENSSL_USE_STATIC_LIBS FALSE)'

        mkdir -p node_modules
        cp -r ${libdatachannelBuildDeps}/node_modules/. node_modules/
        patchShebangs --build node_modules

        export npm_config_nodedir=${pkgs.lib.getDev pkgs.nodejs_22}

        node_modules/.bin/cmake-js compile \
            --CDFETCHCONTENT_SOURCE_DIR_LIBDATACHANNEL=${libdatachannel} \
            --CDFETCHCONTENT_FULLY_DISCONNECTED=ON

        find build -mindepth 1 -maxdepth 1 -not -name Release -exec rm -rf {} +
        find build/Release -mindepth 1 -not -name 'node_datachannel.node' -exec rm -rf {} +
        popd

        wrapProgram $out/bin/torlnk \
          --prefix PATH : ${
            pkgs.lib.makeBinPath [
              pkgs.wl-clipboard
              pkgs.xclip
            ]
          }
      '';

      src = inputs.torlink;
      strictDeps = true;
      version = "2.2.0";

      meta = {
        description = "Torlink is a torrent finder that lives in your terminal, with zero setup and nothing to configure.";
        homepage = "https://github.com/WarlaxZ/torlink";
        license = pkgs.lib.licenses.mit;
        mainProgram = "torlnk";
        platforms = pkgs.lib.platforms.linux;
      };
    };
in
{
  flake-file.inputs = {
    torlink.url = "github:WarlaxZ/torlink";
  };

  den.aspects.applications.productivity.torlink = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = lib.optionals (inputs ? torlink) [
          (torlinkPkg pkgs)
        ];
      };

    persistHome.directories = [
      ".config/torlink"
      ".local/share/torlink"
    ];
  };
}
