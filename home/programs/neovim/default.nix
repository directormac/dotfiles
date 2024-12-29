{ pkgs, ... }:
let
  treesitterWithGrammars = (pkgs.vimPlugins.nvim-treesitter.withPlugins (p: [
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
    #vimPlugins.catppuccin-nvim
    #vimPlugins.tokyonight-nvim
  ];

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;

    plugins = [ treesitterWithGrammars ];
  };

  home.file."./.config/nvim/" = {
    source = ./nvim;
    recursive = true;
  };

  home.file."./.config/nvim/lua/config/lazy.lua".text = ''
    -- Bootstrap lazy.nvim
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
    if not (vim.uv or vim.loop).fs_stat(lazypath) then
      local lazyrepo = "https://github.com/folke/lazy.nvim.git"
      local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
      if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
          { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
          { out, "WarningMsg" },
          { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
      end
    end
    vim.opt.rtp:prepend(lazypath)

    -- Make sure to setup `mapleader` and `maplocalleader` before
    -- loading lazy.nvim so that mappings are correct.
    -- This is also a good place to setup other settings (vim.opt)
    vim.g.mapleader = " "
    vim.g.maplocalleader = "\\"

    -- Setup lazy.nvim
    require("lazy").setup({
      spec = {
        -- import your plugins
        { import = "plugins" },
      },
      -- Configure any other settings here. See the documentation for more details.
      -- colorscheme that will be used when installing plugins.
      install = { colorscheme = { "catppuccin" } },
      -- automatically check for plugin updates
      checker = { enabled = true },
    })

    vim.opt.runtimepath:append("${treesitter-parsers}")
  '';

  # Treesitter is configured as a locally developed module in lazy.nvim
  # we hardcode a symlink here so that we can refer to it in our lazy config
  home.file."./.local/share/nvim/nix/nvim-treesitter/" = {
    recursive = true;
    source = treesitterWithGrammars;
  };
}

