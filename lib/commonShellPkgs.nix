{ ... }: {
  flake = {
    commonShellPkgs =
      pkgs: self': with pkgs; [

        # Nix related
        nil
        nix-inspect
        nixd
        manix
        statix

        # Others
        ffmpeg-full
        p7zip
        sshfs
        unzip
        yt-dlp
        zip

        # Language tools
        tree-sitter

        # CLI Goodies
        bat
        btop
        dust
        fastfetch
        imv
        fd
        file
        fzf
        killall
        lsd
        ripgrep
        vivid
        wget
        yazi
        zoxide

        # wrapped
        self'.packages.qalc
        self'.packages.nix-check-bin
        self'.packages.nh
        self'.packages.lazygit
      ];
  };
}
