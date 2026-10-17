# Core CLI Utilities & System Inspection Tools Leaf Aspect
{
  den.aspects.applications.shell.cli-utils = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = with pkgs; [
          # Download & Network
          aria2
          curl
          wget

          # System & Hardware Inspection
          inotify-tools
          lshw
          lsof
          pciutils
          usbutils

          # Archiving & Compression
          _7zip-zstd
          _7zz
          _7zz-rar
          unzip
          unrar
          zip

          # CLI Goodies
          skim
          dust
          fd
          file
          ghgrab
          jq
          yq
          killall
          lsd
          ncdu
          ripgrep
          trash-cli
        ];
      };

    homeManager =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          skim
          bottom
          duf
          dust
          eza
          fd
          hyperfine
          jq
          yq
          killall
          pciutils
          procs
          ripgrep
          usbutils
        ];
      };
  };
}
