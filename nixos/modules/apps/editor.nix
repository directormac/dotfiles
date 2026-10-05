{ inputs, self, ... }: {

  flake.homeModules.editor = { pkgs, config, ... }: {

    home = {
      file = {
        ".config/helix" = {
          source = config.lib.file.mkOutOfStoreSymlink ../../../config/helix;
        };
        ".config/vim" = {
          source = config.lib.file.mkOutOfStoreSymlink ../../../config/vim;
        };
      };
      packages = with pkgs; [
        (pkgs.writeShellScriptBin "neovim" ''
          exec env NVIM_APPNAME=nvim ${nvim-pkg}/bin/nvim "$@"
        '')
      ];
    };

    xdg.desktopEntries = {
      neovim = {
        name = "Neovim";
        genericName = "Text Editor";
        comment = "Manage text files";
        # exec = "kitty -e neovim %F";
        exec = "ghostty --class=com.neovim.editor -e nvim %F";
        terminal = false; # Handled by the terminal execution string above
        type = "Application";
        icon = "nvim";
        categories = [
          "Utility"
          "TextEditor"
          "Development"
        ];
        mimeType = [
          "text/plain"
          "text/x-chdr"
          "text/x-csrc"
          "text/x-c++hdr"
          "text/x-c++src"
          "text/csv"
          "application/json"
          "application/x-zerosize"
        ];
      };

      nvim = {
        name = "Neovim";
        exec = "nvim %F";
        type = "Application";
        settings = {
          NoDisplay = "true"; # This forces launchers to ignore this entry entirely
        };
      };

    };

    programs.vim = {
      enable = true;
      extraConfig = ''
        let g:is_nix = 1
        packloadall
        source ~/.config/vim/vimrc
      '';
      plugins = with pkgs.vimPlugins; [
        vim-sleuth
        vim-commentary
        vim-gitgutter
        vim-which-key
        vim-vinegar
        fzf-vim
        vim-lsp
        vim-lsp-settings
        vim-airline
        asyncomplete-vim
        asyncomplete-lsp-vim
        catppuccin-vim
        # neoformat
      ];

    };

    programs.helix.enable = true;

  };

  flake.nixosModules.editor = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        editor
      ];
    };

    nixpkgs.overlays = [ inputs.kickstart-nix-nvim.overlays.default ];

    environment.systemPackages = with pkgs; [
      config.treefmt.build.wrapper
      # Editor tools
      tree-sitter
      nixfmt
      stylua
      lua-language-server
      # shfmt
      bash-language-server
      nixd
      nil

      pkgs.nur.repos.Freed-Wu.lsp-tree-sitter
      pkgs.nur.repos.Freed-Wu.tree-sitter-tmux
      pkgs.nur.repos.Freed-Wu.tmux-language-server
      pkgs.nur.repos.Freed-Wu.termux-language-server
    ];

  };

}
