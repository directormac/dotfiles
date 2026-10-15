# Editor Aspect: Helix and Vim with out-of-store symlinks to dotsConfigPath
_:
{
  core.editor = {
    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
      in
      {
        home.file = {
          ".config/helix".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/helix";
          ".config/vim".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/vim";
        };

        home.packages = [ pkgs.helix ];

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
          ];
        };
      };

    # Persistence paths for vim/helix undo and state
    persistHome.directories = [
      ".local/state/vim"
      ".local/share/helix"
    ];
  };
}
