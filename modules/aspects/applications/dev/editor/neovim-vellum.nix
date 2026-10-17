# Minimal Neovim Markdown Viewer with Vellum & FFF
{
  inputs,
  self,
  ...
}:
{
  flake-file.inputs = {
    neovim-nightly-overlay = {
      inputs.nixpkgs.follows = "nixpkgs";
      url = "github:nix-community/neovim-nightly-overlay";
    };
  };

  den.aspects.applications.dev.editor.neovim-vellum = {
    homeManager =
      { ... }:
      {
        imports = [ self.wrappers.neovim-vellum.install ];
        wrappers.neovim-vellum.enable = true;
      };
  };

  flake.wrappers.neovim-vellum =
    {
      pkgs,
      wlib,
      ...
    }:
    let
      vellum-nvim = import ./_vellum.nix { inherit pkgs; };
      vellumConfigDir = pkgs.writeTextDir "init.lua" /* lua */ ''
        vim.g.mapleader = ' '
        vim.g.maplocalleader = ' '

        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.termguicolors = true
        vim.opt.wrap = true
        vim.opt.signcolumn = 'yes'

        -- Catppuccin Mocha with transparency
        local ok_cat, catppuccin = pcall(require, 'catppuccin')
        if ok_cat and catppuccin.setup then
          catppuccin.setup({
            flavour = 'mocha',
            transparent_background = true,
            float = {
              transparent = true,
              solid = false,
            },
            term_colors = true,
          })
        end
        vim.cmd.colorscheme('catppuccin')

        -- Statusline via mini.statusline
        local ok_ms, statusline = pcall(require, 'mini.statusline')
        if ok_ms and statusline.setup then
          statusline.setup({ use_icons = true })
        end

        -- Vellum setup
        local ok_vellum, vellum = pcall(require, 'vellum')
        if ok_vellum and vellum.setup then
          vellum.setup({})
        end

        -- FFF setup with markdown-only restriction
        local ok_fff, fff = pcall(require, 'fff')
        if ok_fff and fff.setup then
          fff.setup({
            title = ' Markdown Fuzzy Finder ',
            prompt = ' ',
            layout = {
              height = 0.8,
              width = 0.8,
              prompt_position = 'top',
              preview_position = 'right',
              preview_size = 0.5,
            },
            preview = { enabled = true },
            git = { status_text_color = true },
            grep = { smart_case = true },
          })

          -- Intercept search_files_paginated to filter strictly to markdown files
          local ok_fp, fp = pcall(require, 'fff.file_picker')
          if ok_fp and fp.search_files_paginated then
            local orig_search = fp.search_files_paginated
            fp.search_files_paginated = function(...)
              local res = orig_search(...)
              local filtered = {}
              for _, item in ipairs(res or {}) do
                local p = item.relative_path or item.name or ""
                if p:match('%.md$') or p:match('%.markdown$') or p:match('%.MD$') then
                  table.insert(filtered, item)
                end
              end
              return filtered
            end
          end

          -- Intercept grep_renderer to filter strictly to markdown files
          local ok_grep, grep_renderer = pcall(require, 'fff.picker_ui.grep_renderer')
          if ok_grep and grep_renderer.search then
            local orig_grep = grep_renderer.search
            grep_renderer.search = function(query, file_offset, page_size, config, grep_mode)
              local res = orig_grep(query, file_offset, page_size, config, grep_mode)
              if res and res.items then
                local filtered = {}
                for _, item in ipairs(res.items) do
                  local p = item.relative_path or item.name or ""
                  if p:match('%.md$') or p:match('%.markdown$') or p:match('%.MD$') then
                    table.insert(filtered, item)
                  end
                end
                res.items = filtered
                res.total_matched = #filtered
              end
              return res
            end
          end
        end

        -- Keymaps
        vim.keymap.set('n', '<leader><leader>', function()
          if ok_fff then require('fff').find_files() end
        end, { desc = 'Find Markdown Files (fff)' })

        vim.keymap.set('n', '<leader>ff', function()
          if ok_fff then require('fff').find_files() end
        end, { desc = 'Find Markdown Files (fff)' })

        vim.keymap.set('n', '<leader>/', function()
          if ok_fff then require('fff').live_grep() end
        end, { desc = 'Live Grep Markdown (fff)' })

        vim.keymap.set('n', '<leader>v', function()
          if ok_vellum then require('vellum').toggle() end
        end, { desc = 'Toggle Vellum Preview' })

        -- Auto-open Vellum live side preview on markdown files
        vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufEnter' }, {
          pattern = { '*.md', '*.markdown' },
          callback = function(ev)
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(ev.buf) and vim.bo[ev.buf].filetype == 'markdown' then
                if ok_vellum then
                  pcall(vellum.open)
                end
              end
            end)
          end,
        })

        -- If opened without arguments, launch fff markdown finder
        vim.api.nvim_create_autocmd('VimEnter', {
          callback = function()
            if vim.fn.argc() == 0 and ok_fff then
              require('fff').find_files()
            end
          end,
          once = true,
        })
      '';
    in
    {
      imports = [ wlib.wrapperModules.neovim ];
      config.binName = "nvim-vellum";
      config.env.PUPPETEER_EXECUTABLE_PATH = "${pkgs.chromium}/bin/chromium";
      config.package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;

      config.runtimePkgs = with pkgs; [
        nodejs
        chromium
        ripgrep
        fd
      ];

      config.settings.aliases = [ "vellum" ];
      config.settings.block_normal_config = true;
      config.settings.config_directory = vellumConfigDir;
      config.settings.dont_link = true;

      config.specs.colorscheme = {
        data = pkgs.vimPlugins.catppuccin-nvim;
        lazy = false;
      };

      config.specs.general = {
        data = with pkgs.vimPlugins; [
          vellum-nvim
          fff-nvim
          plenary-nvim
          mini-nvim
          catppuccin-nvim
          nvim-treesitter.withAllGrammars
          nvim-web-devicons
        ];

        lazy = false;
      };
    };
}
