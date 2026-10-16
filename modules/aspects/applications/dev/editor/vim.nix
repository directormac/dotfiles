# Vim Editor Aspect
_:
{
  den.aspects.applications.dev.editor.vim = {
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
        home.file.".config/vim".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/vim";

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

    persistHome.directories = [
      ".local/state/vim"
    ];
  };
}
