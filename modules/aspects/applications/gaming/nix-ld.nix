# Nix-LD & Nix-Index Aspect: Run unpatched dynamic binaries on NixOS
{
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  den.aspects.applications.gaming.nix-ld = {
    nixos =
      { lib, pkgs, ... }:
      {
        imports = lib.optionals (inputs ? nix-index-database) [
          inputs.nix-index-database.nixosModules.nix-index
        ];

        environment.systemPackages = [
          pkgs.nix-index
        ];

        programs.command-not-found.enable = lib.mkDefault false;

        programs.nix-index-database.comma.enable = lib.mkIf (inputs ? nix-index-database) true;

        programs.nix-index = {
          enable = lib.mkDefault true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };

        programs.zsh.interactiveShellInit = ''
          source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
        '';

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
}
