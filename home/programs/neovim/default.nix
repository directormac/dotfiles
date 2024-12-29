{ pkgs, ... }:
let
  treesitterWithGrammars = (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
    # p.ansible
    p.bash
    p.comment
    p.css
    p.dockerfile
    p.fish
    p.gitattributes
    p.gitignore
    p.go
    p.gomod
    p.gowork
    p.hcl
    p.javascript
    p.jq
    p.json5
    p.json
    p.lua
    p.make
    p.markdown
    p.nix
    p.python
    p.svelte
    p.rust
    p.toml
    p.svelte
    p.typescript
    p.vue
    p.yaml
  ]));

  treesitter-parsers = pkgs.symlinkJoin {
    name = "treesitter-parsers";
    paths = treesitterWithGrammars.dependencies;
  };
in {
  home.packages = with pkgs; [
    # Language Servers and Tools
    ansible-language-server
    ansible-lint
    astro-language-server
    biome
    clang-tools
    docker-compose-language-service
    dockerfile-language-server-nodejs
    elixir-ls
    emmet-ls
    eslint
    eslint_d
    gofumpt
    gotools
    gopls
    hadolint
    helm-ls
    ktlint
    kotlin-language-server
    lua-language-server
    haskellPackages.nixfmt
    nls
    ruff
    ruff-lsp
    rust-analyzer
    svelte-language-server
    typescript-language-server
    vue-language-server

    # Themes
    vimPlugins.catppuccin-nvim
    vimPlugins.tokyonight-nvim
  ];

  programs.neovim = {
    enable = true;
    package = pkgs.neovim;
    vimAlias = true;
    coc.enable = false;
    withNodeJs = true;

    plugins = [ treesitterWithGrammars ];
  };

  home.file."./.config/nvim/" = {
    source = ./nvim;
    recursive = true;
  };

  home.file."./.config/nvim/lua/artifex/init.lua".text = ''
    require("artifex.set")
    require("artifex.remap")
    vim.opt.runtimepath:append("${treesitter-parsers}")
  '';

  # Treesitter is configured as a locally developed module in lazy.nvim
  # we hardcode a symlink here so that we can refer to it in our lazy config
  home.file."./.local/share/nvim/nix/nvim-treesitter/" = {
    recursive = true;
    source = treesitterWithGrammars;
  };
}

