local M = {}

local colors = {
  SnacksIndent1 = '#f38ba8', -- red
  SnacksIndent2 = '#fab387', -- peach
  SnacksIndent3 = '#f9e2af', -- yellow
  SnacksIndent4 = '#a6e3a1', -- green
  SnacksIndent5 = '#94e2d5', -- teal
  SnacksIndent6 = '#89b4fa', -- blue
  SnacksIndent7 = '#cba6f7', -- mauve
  SnacksIndent8 = '#f5c2e7', -- pink
  SnacksIndentScope = '#cba6f7', -- mauve accent for active scope
  SnacksIndentChunk = '#89b4fa', -- blue accent for chunk
}

local function set_highlights()
  for group, fg in pairs(colors) do
    vim.api.nvim_set_hl(0, group, { fg = fg, default = false })
  end
end

M.opts = {
  indent = {
    priority = 1,
    enabled = true,
    char = '│',
    only_scope = false,
    only_current = false,
    hl = {
      'SnacksIndent1',
      'SnacksIndent2',
      'SnacksIndent3',
      'SnacksIndent4',
      'SnacksIndent5',
      'SnacksIndent6',
      'SnacksIndent7',
      'SnacksIndent8',
    },
    filter = function(buf)
      return vim.g.snacks_indent ~= false and vim.b[buf].snacks_indent ~= false and vim.bo[buf].buftype == ''
    end,
  },
  animate = {
    enabled = vim.fn.has('nvim-0.10') == 1,
    style = 'out',
    easing = 'linear',
    duration = {
      step = 20,
      total = 500,
    },
  },
  scope = {
    enabled = true,
    priority = 200,
    char = '│',
    underline = false,
    only_current = false,
    hl = 'SnacksIndentScope',
  },
  chunk = {
    enabled = false,
    priority = 200,
    hl = 'SnacksIndentChunk',
    char = {
      corner_top = '┌',
      corner_bottom = '└',
      horizontal = '─',
      vertical = '│',
      arrow = '>',
    },
  },
}

function M.setup()
  set_highlights()
  vim.api.nvim_create_autocmd('ColorScheme', {
    group = vim.api.nvim_create_augroup('SnacksIndentColors', { clear = true }),
    callback = set_highlights,
  })
end

function M.keys() Snacks.toggle.indent():map('<leader>ug') end

return M
