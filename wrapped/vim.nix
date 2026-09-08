{ self, ... }: {
  perSystem = { pkgs, lib, ... }: {
    packages.my-vim =
      let
        # 1. Define all your plugins here.
        my-plugins = with pkgs.vimPlugins; [
          vim-sleuth
          vim-commentary
          vim-gitgutter
          vim-which-key
          fzf-vim
          vim-lsp
          vim-lsp-settings
          asyncomplete-vim
          asyncomplete-lsp-vim
          catppuccin-vim
          vim-airline
        ];

        # 2. Add external dependencies (fzf, rg) and Language Servers
        my-packages = with pkgs; [
          ripgrep
          fzf
          # LSPs:
          nil # Nix LSP
          clang-tools # C/C++ LSP
        ];

        # 3. Create the customized Vim (this builds a vim with native packpath plugins)
        customVim = pkgs.vim-full.customize {
          name = "vim";
          vimrcConfig = {
            packages.myVimPackage = {
              start = my-plugins;
            };

            # Inject a global variable before reading your vimrc!
            customRC = ''
              		  let g:is_nix = 1
              		  source ${self}/config/vim/vimrc
            '';
          };
        };

      in
      # 4. Wrap the custom Vim so it has access to fzf, ripgrep, and LSPs in its PATH
      pkgs.symlinkJoin {
        name = "my-vim-wrapped";
        paths = [ customVim ];
        nativeBuildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/vim \
            --prefix PATH : "${lib.makeBinPath my-packages}"
        '';
      };
  };
}
