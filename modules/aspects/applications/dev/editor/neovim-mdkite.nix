# Minimal Neovim Markdown Viewer with Mdkite & FFF
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

  den.aspects.applications.dev.editor.neovim-mdkite = {
    homeManager =
      { ... }:
      {
        imports = [ self.wrappers.neovim-mdkite.install ];
        wrappers.neovim-mdkite.enable = true;
      };
  };

  flake.wrappers.neovim-mdkite =
    {
      config,
      pkgs,
      wlib,
      ...
    }:
    let
      kitehost-nvim = config.nvim-lib.mkPlugin "kitehost-nvim" inputs.vim-plugins-kitehost-nvim;
      mdkite-nvim = config.nvim-lib.mkPlugin "mdkite-nvim" inputs.vim-plugins-mdkite-nvim;
      mdkiteConfigDir = pkgs.writeTextDir "init.lua" /* lua */ ''
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

        -- Mdkite setup
        local ok_mdkite, mdkite = pcall(require, 'mdkite')
        if ok_mdkite and mdkite.setup then
          mdkite.setup({
            instance_mode = 'takeover',
            open_browser = true,
            mermaid_renderer = 'rust',
            default_theme = 'dark',
            debounce_ms = 200,
          })
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

        -- Toggle Mdkite preview
        vim.keymap.set('n', '<leader>v', function()
          if ok_mdkite then require('mdkite').toggle() end
        end, { desc = 'Toggle MdKite Preview' })

        vim.keymap.set('n', '<leader>mp', function()
          if ok_mdkite then require('mdkite').toggle() end
        end, { desc = 'Toggle MdKite Preview' })

        -- Preview markdown with mdcat in terminal bottom window
        local function preview_markdown_mdcat()
          local file = vim.api.nvim_buf_get_name(0)
          local tmpfile = nil
          if file == "" or vim.bo.modified then
            tmpfile = vim.fn.tempname() .. ".md"
            local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            vim.fn.writefile(lines, tmpfile)
            file = tmpfile
          end

          local height = math.max(12, math.floor(vim.o.lines * 0.35))
          vim.cmd("botright " .. height .. "split")
          local win = vim.api.nvim_get_current_win()
          local term_cmd = string.format("mdcat -p %s", vim.fn.shellescape(file))
          if tmpfile then
            term_cmd = string.format("mdcat -p %s; rm -f %s", vim.fn.shellescape(file), vim.fn.shellescape(tmpfile))
          end

          vim.fn.termopen(term_cmd, {
            on_exit = function()
              if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
            end,
          })
          vim.cmd("startinsert")
        end

        vim.keymap.set('n', '<leader>mc', preview_markdown_mdcat, {
          desc = 'Preview Markdown with mdcat (bottom window)',
        })

        -- Auto-open MdKite live preview on markdown files
        vim.api.nvim_create_autocmd({ 'BufReadPost', 'BufEnter' }, {
          pattern = { '*.md', '*.markdown' },
          callback = function(ev)
            vim.schedule(function()
              if vim.api.nvim_buf_is_valid(ev.buf) and vim.bo[ev.buf].filetype == 'markdown' then
                if ok_mdkite then
                  pcall(mdkite.start)
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
      config.binName = "nvim-mdkite";
      config.package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;

      config.runtimePkgs = with pkgs; [
        mermaid-cli
        mdcat
        ripgrep
        fd
      ];

      config.settings.aliases = [
        "nvim-vellum"
        "mdkite"
        "vellum"
      ];

      config.settings.block_normal_config = true;
      config.settings.config_directory = mdkiteConfigDir;
      config.settings.dont_link = true;

      config.specs.colorscheme = {
        data = pkgs.vimPlugins.catppuccin-nvim;
        lazy = false;
      };

      config.specs.general = {
        data = with pkgs.vimPlugins; [
          mdkite-nvim
          kitehost-nvim
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
