{ inputs, self, ... }: {

  flake.homeModules.editor = { pkgs, config, ... }: {

    home.file.".config/helix".source = config.lib.file.mkOutOfStoreSymlink ../../../config/helix;

    home.file.".config/vim".source = config.lib.file.mkOutOfStoreSymlink ../../../config/vim;

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

    home.packages = with pkgs; [
      (pkgs.writeShellScriptBin "neovim" ''
        exec env NVIM_APPNAME=nvim ${nvim-pkg}/bin/nvim "$@"
      '')
    ];

  };

  flake.nixosModules.editor = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = with self.homeModules; [
        editor
      ];
    };

    nixpkgs.overlays = [ inputs.kickstart-nix-nvim.overlays.default ];

    environment.systemPackages = with pkgs; [
      helix

      # Editor tools
      tree-sitter
      nixfmt
      stylua
      lua-language-server
      nixd
      nil
    ];

  };

}
