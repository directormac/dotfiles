{
  self,
  inputs,
  ...
}:
{
  flake.nixosModules.general =
    {
      pkgs,
      config,
      ...
    }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {

      imports = [

        self.nixosModules.multiplexer

        self.nixosModules.yazi
        self.nixosModules.zsh

      ];

      users.users.${config.preferences.user.name} = {
        shell = pkgs.zsh;
      };

      security.sudo-rs.enable = true;

      fonts.packages = with pkgs; [
        nerd-fonts.symbols-only
        nerd-fonts.fira-mono

        noto-fonts
        corefonts
        unifont
        cm_unicode
      ];

      environment.sessionVariables = {
        EDITOR = "lvim";
      };

      # https://wiki.nixos.org/wiki/Nix-ld
      programs.nix-ld = {
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

      programs.nix-index = {
        enable = true;
        enableBashIntegration = true;
        enableZshIntegration = true;
      };

      programs.command-not-found.enable = false;

      programs.zsh.interactiveShellInit = ''
        source ${pkgs.nix-index}/etc/profile.d/command-not-found.sh
      '';

      environment.systemPackages = with pkgs; [
        # Nix
        nix-index
        inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien

        # Common
        wget
        cifs-utils
        inotify-tools
        lshw
        nfs-utils
        ntfs3g
        p7zip
        pciutils
        sshfs
        unzip
        zip

        # Dev tools
        tree-sitter
        git
        github-cli

        vim
        neovim

        devenv
        secretspec

        # CLI Goodies

        bat
        btop
        dust
        fastfetch
        fd
        file
        fzf
        ghgrab
        imv
        killall
        lsd
        ripgrep
        starship
        tealdeer
        television
        vivid
        wget
        zoxide

        selfpkgs.nh
        selfpkgs.yazi
        selfpkgs.lazygit
      ];

    };
}
