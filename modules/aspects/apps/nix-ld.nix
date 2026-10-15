# Nix-LD Aspect: Run unpatched dynamic binaries on NixOS
{ core, ... }:
{
  core.nix-ld = {
    nixos =
      { lib, pkgs, ... }:
      {
        programs.command-not-found.enable = lib.mkDefault false;

        programs.nix-index = {
          enable = lib.mkDefault true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        programs.nix-ld = {
          enable = lib.mkDefault true;

          libraries = with pkgs; [
            acl
            alsa-lib
            attr
            bzip2
            curl
            dbus
            fontconfig
            freetype
            glib
            gtk2
            libGL
            libGLX
            libX11
            libsodium
            libssh
            libxcb
            libxcb-cursor
            libxcb-errors
            libxcb-image
            libxcb-keysyms
            libxcb-render-util
            libxcb-util
            libxcb-wm
            libxkbcommon
            libxml2
            openssl
            stdenv.cc.cc
            systemd
            util-linux
            xz
            zlib
            zstd
          ];
        };
      };

    cacheHome.directories = [
      ".cache/nix-index"
    ];
  };

  den.aspects.nixos.includes = [
    core.nix-ld
  ];

  den.aspects.sandbox.includes = [
    core.nix-ld
  ];

  den.aspects.super.includes = [
    core.nix-ld
  ];
}
