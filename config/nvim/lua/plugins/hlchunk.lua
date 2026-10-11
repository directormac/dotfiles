return {
  'hlchunk.nvim',
  event = { 'BufReadPre', 'BufNewFile' },
  after = function()
    --- Configuration Reference https://github.com/shellraining/hlchunk.nvim#setup
    require('hlchunk').setup({
      -- https://github.com/shellRaining/hlchunk.nvim/blob/main/docs/en/chunk.md
      chunk = {
        enable = true,
        duration = 100,
        delay = 500,
        -- Dotted
        chars = {
          horizontal_line = '┅',
          left_top = '┏',
          vertical_line = '┇',
          left_bottom = '┗',
          right_arrow = '┅',
        },

        -- Square
        -- chars = {
        --   horizontal_line = '━',
        --   left_top = '┏',
        --   vertical_line = '┃',
        --   left_bottom = '┗',
        --   right_arrow = '━',
        -- },
      },
      -- https://github.com/shellRaining/hlchunk.nvim/blob/main/docs/en/blank.md
      blank = {
        enable = true,
        chars = {
          ' ',
          '․',
          '⁚',
          '⁖',
          '⁘',
          '⁙',
        },
        style = {
          -- { vim.fn.synIDattr(vim.fn.synIDtrans(vim.fn.hlID('Whitespace')), 'fg', 'gui'), '' },
          '#585b70',
          '#45475a',
          '#313244',
        },
      },
      line_num = {
        enable = true,
        style = '#cba6f7',
      },
      indent = {
        enable = false,
        chars = {
          '│',
          '¦',
          '┆',
          '┊',
        },
        style = {
          '#f38ba8', -- red
          '#fab387', -- peach
          '#f9e2af', -- yellow
          '#a6e3a1', -- green
          '#94e2d5', -- teal
          '#89b4fa', -- blue
          '#cba6f7', -- mauve
          '#f5c2e7', -- pink
          '#cba6f7', -- mauve accent for active scope
          '#89b4fa', -- blue accent for chunk
        },
      },
    })
  end,
}
