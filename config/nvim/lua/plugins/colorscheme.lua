return {
  'catppuccin-nvim',
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
    vim.api.nvim_create_autocmd({ 'ColorScheme', 'InsertEnter', 'InsertLeave', 'ModeChanged' }, {
      callback = function()
        vim.cmd('hi LineNr guifg=#6c7086')
        vim.cmd('hi LineNrAbove guifg=#6c7086')
        vim.cmd('hi LineNrBelow guifg=#6c7086')
        vim.cmd('hi CursorLineNr guifg=#cba6f7 gui=bold')
        vim.cmd('hi CursorLine guibg=#313244')
      end,
    })
  end,
}
