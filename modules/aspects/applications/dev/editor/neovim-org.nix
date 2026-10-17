# Minimal Neovim Org Mode Variant with org-nvim, fff, and mini.statusline
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

    vim-plugins-org-nvim = {
      flake = false;
      url = "github:xheisenbugx/org.nvim";
    };
  };

  den.aspects.applications.dev.editor.neovim-org = {
    homeManager =
      { ... }:
      {
        imports = [ self.wrappers.neovim-org.install ];
        wrappers.neovim-org.enable = true;
      };
  };

  flake.wrappers.neovim-org =
    {
      config,
      pkgs,
      wlib,
      ...
    }:
    let
      org-nvim = config.nvim-lib.mkPlugin "org-nvim" inputs.vim-plugins-org-nvim;
      orgConfigDir = pkgs.writeTextDir "init.lua" /* lua */ ''
        vim.g.mapleader = ' '
        vim.g.maplocalleader = ' '

        vim.opt.number = true
        vim.opt.relativenumber = true
        vim.opt.termguicolors = true
        vim.opt.wrap = true
        vim.opt.signcolumn = 'yes'

        -- Always ensure working directory is ~/Notes
        local notes_dir = vim.fn.expand('~/Notes')
        if vim.fn.isdirectory(notes_dir) == 0 then
          pcall(vim.fn.mkdir, notes_dir, 'p')
        end
        pcall(vim.fn.chdir, notes_dir)

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

        -- Org setup
        local ok_org, org = pcall(require, 'org')
        if ok_org and org.setup then
          org.setup({
            org_directory = notes_dir,
            agenda_files = { notes_dir .. '/**/*.org' },
            default_notes_file = notes_dir .. '/refile.org',
          })
        end

        -- FFF setup with org-only restriction and base_path ~/Notes
        local ok_fff, fff = pcall(require, 'fff')
        if ok_fff and fff.setup then
          fff.setup({
            base_path = notes_dir,
            title = ' Org Fuzzy Finder ',
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

          -- Intercept search_files_paginated to filter strictly to org files
          local ok_fp, fp = pcall(require, 'fff.file_picker')
          if ok_fp and fp.search_files_paginated then
            local orig_search = fp.search_files_paginated
            fp.search_files_paginated = function(...)
              local res = orig_search(...)
              local filtered = {}
              for _, item in ipairs(res or {}) do
                local p = item.relative_path or item.name or ""
                if p:match('%.org$') then
                  table.insert(filtered, item)
                end
              end
              return filtered
            end
          end

          -- Intercept grep_renderer to filter strictly to org files
          local ok_grep, grep_renderer = pcall(require, 'fff.picker_ui.grep_renderer')
          if ok_grep and grep_renderer.search then
            local orig_grep = grep_renderer.search
            grep_renderer.search = function(query, file_offset, page_size, config, grep_mode)
              local res = orig_grep(query, file_offset, page_size, config, grep_mode)
              if res and res.items then
                local filtered = {}
                for _, item in ipairs(res.items) do
                  local p = item.relative_path or item.name or ""
                  if p:match('%.org$') then
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
          if ok_fff then require('fff').find_files({ cwd = notes_dir }) end
        end, { desc = 'Find Org Files (fff)' })

        vim.keymap.set('n', '<leader>ff', function()
          if ok_fff then require('fff').find_files({ cwd = notes_dir }) end
        end, { desc = 'Find Org Files (fff)' })

        vim.keymap.set('n', '<leader>/', function()
          if ok_fff then require('fff').live_grep({ cwd = notes_dir }) end
        end, { desc = 'Live Grep Org (fff)' })

        vim.keymap.set('n', '<leader>oa', function()
          if ok_org then vim.cmd('Org agenda') end
        end, { desc = 'Org Agenda' })

        vim.keymap.set('n', '<leader>oc', function()
          if ok_org then vim.cmd('Org capture') end
        end, { desc = 'Org Capture' })

        -- If opened without arguments, open refile.org or fff inside ~/Notes
        vim.api.nvim_create_autocmd('VimEnter', {
          callback = function()
            if vim.fn.argc() == 0 then
              local default_file = notes_dir .. '/refile.org'
              if vim.fn.filereadable(default_file) == 1 then
                vim.cmd.edit(default_file)
              elseif ok_fff then
                require('fff').find_files({ cwd = notes_dir })
              end
            end
          end,
          once = true,
        })
      '';
    in
    {
      imports = [ wlib.wrapperModules.neovim ];
      config.binName = "nvim-org";
      config.package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.neovim;

      config.runtimePkgs = with pkgs; [
        ripgrep
        fd
      ];

      config.settings.aliases = [
        "org-nvim"
        "org"
      ];

      config.settings.block_normal_config = true;
      config.settings.config_directory = orgConfigDir;
      config.settings.dont_link = true;

      config.specs.colorscheme = {
        data = pkgs.vimPlugins.catppuccin-nvim;
        lazy = false;
      };

      config.specs.general = {
        data = with pkgs.vimPlugins; [
          org-nvim
          fff-nvim
          mini-nvim
          catppuccin-nvim
          plenary-nvim
          nvim-treesitter.withAllGrammars
          nvim-web-devicons
        ];

        lazy = false;
      };
    };
}
