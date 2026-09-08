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

        # 2. Add external dependencies (fzf, rg) and Language Servers
        my-packages = with pkgs; [
          ripgrep
          fzf
          # LSPs:
          nil # Nix LSP
          clang-tools # C/C++ LSP
          lua-language-server

          nixfmt # Formatter for nix
          stylua # Formatter for Lua
        ];

        # 3. Create the customized Vim (this builds a vim with native packpath plugins)
        customVim = pkgs.vim-full.customize {
          name = "vim";
          vimrcConfig = {
            packages.myVimPackage = {
              start = my-plugins;
            };

            # Inject the flag and source the LIVE file from your home directory
            customRC = ''
              		  let g:is_nix = 1
              		
              		  " Check if the symlink exists before sourcing, so it doesn't error if missing
              		  if filereadable(expand("$HOME/.config/vim/vimrc"))
                              source $HOME/.config/vim/vimrc
              		  endif
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
