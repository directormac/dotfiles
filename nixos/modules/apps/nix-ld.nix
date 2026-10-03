{
  flake.nixosModules.nix-ld = { pkgs, ... }: {

    # https://wiki.nixos.org/wiki/Nix-ld
    programs = {
      nix-ld = {
        enable = true;
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
      nix-index = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };
      command-not-found.enable = false;
      zsh.interactiveShellInit = ''
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      '';
    };
  };
}
