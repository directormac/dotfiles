{ ... }: {
  flake = {
    commonShellPkgs =
      pkgs: self': with pkgs; [

        # Nix related
        nil
        nix-inspect
        nixfmt
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
        lua-language-server
        stylua

        github-cli
        neovim
        vim

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

        tmux

        # wrapped
        self'.packages.qalc
        self'.packages.nix-check-bin
        self'.packages.nh
        self'.packages.lazygit
      ];
  };
}
