-- Colorscheme loading: a lazy spec that schedules `:colorscheme`,
-- plus the catppuccin-nvim plugin itself.
return {
  {
    -- lze specs need a name
    'trigger_colorscheme',
    -- lazy loaded colorscheme.
    -- This means you will need to add the colorscheme you want to lze sometime before VimEnter is done
    event = 'VimEnter',
    -- Also, lze can load more than just plugins.
    -- The default load field contains vim.cmd.packadd
    -- Here we override it to schedule when our colorscheme is loaded
    load = function(_name)
      -- schedule so it runs after VimEnter
      vim.schedule(function()
        vim.cmd.colorscheme(nixInfo('catppuccin', 'settings', 'colorscheme'))
        vim.schedule(function()
          -- I like this color. Use vim.schedule again to set it after the colorscheme is finished
          vim.cmd([[hi LineNr guifg=#bb9af7]])
        end)
      end)
    end,
  },
  {
    -- NOTE: view these names in the info plugin!
    -- :lua nixInfo.lze.debug.display(nixInfo.plugins)
    -- The display function is from lzextras
    'catppuccin-nvim',
    auto_enable = true,
    -- NOTE: this must be the *colorscheme name* used by `:colorscheme` below
    -- (which comes from the nix option `settings.colorscheme`), not the plugin name.
    -- Neovim ships its own colors/catppuccin.vim, so if this does not match,
    -- the plugin is never loaded and `after` below never runs.
    colorscheme = 'catppuccin',
    after = function(_)
      require('catppuccin').setup({
        flavour = 'mocha',
        background = { light = 'latte', dark = 'mocha' },
        transparent_background = true,
        term_colors = true,
        integrations = {
          blink_cmp = true,
          bufferline = true,
          gitsigns = true,
          nvimtree = true,
          snacks = true,
          treesitter = true,
          which_key = true,
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { 'italic' },
              hints = { 'italic' },
              warnings = { 'italic' },
              information = { 'italic' },
            },
            underlines = { errors = { 'underline' }, hints = { 'underline' } },
          },
        },
      })
    end,
  },
}
