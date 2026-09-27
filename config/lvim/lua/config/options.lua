local global = vim.g
local set = vim.opt
local window = vim.w

global.loaded_netrwPlugin = 1 -- Override for oil explorer
global.neoterm_autoinsert = 0 -- Do not start terminal in insert mode
global.neoterm_autoscroll = 1 -- Autoscroll the terminal
global.markdown_recommended_style = 0 -- Fix markdown indentation settings
global.lazyvim_prettier_needs_config = true
global.lazyvim_eslint_auto_format = false

-- Motivation: Less clutter in completion windows and a more direct usage of snippets
global.lazyvim_mini_snippets_in_completion = false

global.lazyvim_blink_main = false
global.lazyvim_picker = 'snacks'
global.lazydev_enabled = true
global.lazyvim_ts_lsp = 'tsc'

set.clipboard = 'unnamedplus'
set.exrc = true

set.foldcolumn = '0' -- Show the fold column
set.foldenable = true
set.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
set.foldlevelstart = 99
set.signcolumn = 'yes'
set.termguicolors = true
set.pumblend = 0
set.pumheight = 0
set.winblend = 0
--stylua: ignore
set.fillchars = { fold = " ", foldopen = "", foldclose = "", foldsep = " ", diff = "╱", eob = " ",}
--stylua: ignore
set.listchars = { space = ".", eol = "↲", nbsp = "␣", trail = "·", precedes = "←", extends = "→", tab = "¬ ", conceal = "※", }
set.shortmess = {
  A = true, -- ignore annoying swap file messages
  -- c = true, -- Do not show completion messages in command line
  -- F = true, -- Do not show file info when editing a file, in the command line
  I = true, -- Do not show the intro message
  W = true, -- Do not show "written" in command line when writing
}

-- Window optiosn
window.list = true -- Show some invisible characters like tabs etc
window.numberwidth = 1 -- Make the line number column thinner
---Note: Setting number and relative number gives you hybrid mode
---https://jeffkreeftmeijer.com/vim-number/
window.number = true -- Set the absolute number
window.relativenumber = true -- Set the relative number
window.signcolumn = 'yes' -- Show information next to the line numbers
window.wrap = false -- Do not display text over multiple lines
