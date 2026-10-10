-- Colorscheme loading: a lazy spec that schedules `:colorscheme`,
-- plus the catppuccin-nvim plugin itself.
nixInfo.lze.load({
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
          -- vim.cmd('hi LineNr guifg=#6c7086')
          -- vim.cmd('hi LineNrAbove guifg=#6c7086')
          -- vim.cmd('hi LineNrBelow guifg=#6c7086')
          -- vim.cmd('hi CursorLineNr guifg=#cba6f7 gui=bold')
          -- vim.cmd('hi CursorLine guibg=#313244')
        end)
      end)
    end,
  },
  {
    'catppuccin-nvim',
    auto_enable = true,
    colorscheme = 'catppuccin',
    after = function(_)
      require('catppuccin').setup({
        flavour = 'mocha',
        background = { light = 'latte', dark = 'mocha' },
        transparent_background = true,
        float = {
          transparent = true,
          solid = false,
        },
        term_colors = true,
        -- auto_integrations = true,
        highlight_overrides = {
          mocha = function(colors)
            return {
              LineNr = { fg = colors.overlay0 },
              LineNrAbove = { fg = colors.overlay0 },
              LineNrBelow = { fg = colors.overlay0 },
              CursorLineNr = { fg = colors.mauve, style = { 'bold' } },
              CursorLine = { bg = colors.surface0 },
            }
          end,
        },
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

      -- Set Line Number Colors
      -- vim.api.nvim_create_autocmd({ 'ColorScheme', 'InsertEnter', 'InsertLeave', 'ModeChanged' }, {
      --   callback = function()
      --     vim.cmd('hi LineNr guifg=#6c7086')
      --     vim.cmd('hi LineNrAbove guifg=#6c7086')
      --     vim.cmd('hi LineNrBelow guifg=#6c7086')
      --     vim.cmd('hi CursorLineNr guifg=#cba6f7 gui=bold')
      --     vim.cmd('hi CursorLine guibg=#313244')
      --   end,
      -- })
    end,
  },
  {
    'nvim-colorizer.lua',
    auto_enable = true,
    after = function() require('colorizer').setup() end,
  },
})
