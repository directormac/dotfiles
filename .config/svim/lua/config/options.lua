--@type vim.global
local global = vim.g

--@type vim.opt
local set = vim.opt

--@type vim.w
local window = vim.w

global.loaded_netrw = 1 -- Override for oil explorer
global.loaded_netrwPlugin = 1 -- Override for oil explorer
global.autoformat = true

set.clipboard = "unnamedplus"
set.foldcolumn = "0" -- Show the fold column
set.foldenable = true
set.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
set.foldlevelstart = 99
set.signcolumn = "yes"
set.termguicolors = true
set.pumblend = 0
set.pumheight = 0
set.winblend = 0

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
set.list = true
-- set.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
set.fillchars = { fold = " ", foldopen = "", foldclose = "", foldsep = " ", diff = "╱", eob = " " }
set.listchars = {
  space = ".",
  eol = "↲",
  nbsp = "␣",
  trail = "·",
  precedes = "←",
  extends = "→",
  tab = "¬ ",
  conceal = "※",
}
set.shortmess = {
  A = true, -- ignore annoying swap file messages
  c = true, -- Do not show completion messages in command line
  F = true, -- Do not show file info when editing a file, in the command line
  I = true, -- Do not show the intro message
  W = true, -- Do not show "written" in command line when writing
}

set.expandtab = true -- Convert tabs to spaces
set.shiftwidth = 4 -- Amount to indent with << and >>
set.tabstop = 4 -- How many spaces are shown per Tab
set.softtabstop = 4 -- How many spaces are applied when pressing Tab
set.smarttab = true
set.smartindent = true
set.autoindent = true -- Keep identation from previous line

-- Enable break indent
set.breakindent = true

-- Always show relative line numbers
set.number = true
set.relativenumber = true

-- Show line under cursor
set.cursorline = true

-- Store undos between sessions
set.undofile = true

-- Enable mouse mode, can be useful for resizing splits for example!
set.mouse = "a"

-- Don't show the mode, since it's already in the status line
set.showmode = false

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
set.ignorecase = true
set.smartcase = true

-- Keep signcolumn on by default
set.signcolumn = "yes"

-- Configure how new splits should be opened
set.splitright = true
set.splitbelow = true

-- Minimal number of screen lines to keep above and below the cursor.
set.scrolloff = 5

-- Window optiosn
window.list = true -- Show some invisible characters like tabs etc
window.numberwidth = 1 -- Make the line number column thinner
---Note: Setting number and relative number gives you hybrid mode
---https://jeffkreeftmeijer.com/vim-number/
window.number = true -- Set the absolute number
window.relativenumber = true -- Set the relative number
window.signcolumn = "yes" -- Show information next to the line numbers
window.wrap = false -- Do not display text over multiple lines
