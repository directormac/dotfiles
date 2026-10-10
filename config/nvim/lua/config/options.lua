-- Options. See `:help vim.o`

-- allow .nvim.lua in current dir and parents (project config)
vim.o.exrc = true -- load .nvim.lua from the current dir and parents (project config)

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.opt.fillchars = {
  foldopen = '',
  foldclose = '',
  fold = ' ',
  foldsep = ' ',
  diff = '╱',
  eob = ' ',
}

-- Set highlight on search
vim.opt.hlsearch = true

-- Preview substitutions live, as you type!
vim.opt.inccommand = 'split'

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- Make line numbers default & enable cursorline (LazyVim standard)
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true

-- Enable mouse mode
vim.o.mouse = 'a'

-- Auto-reload files when changed externally
vim.opt.autoread = true

-- Indent
-- vim.o.smarttab = true
vim.opt.cpoptions:append('I')
vim.o.expandtab = true
vim.opt.tabstop = 2 -- Number of visual spaces per TAB
vim.opt.softtabstop = 2 -- Number of spaces per TAB when editing
vim.opt.shiftwidth = 2 -- Number of spaces to use for each step of (auto)indent
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.autoindent = true -- Copy indent from current line when starting a new one

-- stops line wrapping from being confusing
vim.o.breakindent = true

-- Save undo history
vim.o.undofile = true

-- Case-insensitive searching UNLESS \C or capital in search
vim.o.ignorecase = true
vim.o.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = 'yes'

-- Decrease update time
vim.o.updatetime = 250
vim.o.timeoutlen = 300

vim.opt.pumblend = 10 -- Popup blend
vim.opt.pumheight = 100 -- Maximum number of entries in a popup

-- Set completeopt to have a better completion experience
vim.o.completeopt = 'menu,preview,noselect'

-- NOTE: You should make sure your terminal supports this
vim.o.termguicolors = true

vim.g.netrw_liststyle = 0

vim.g.netrw_banner = 0

-- Sync clipboard between OS and Neovim.
vim.schedule(function() vim.opt.clipboard = 'unnamedplus' end)

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Folds: better folding behavior by default
vim.opt.foldlevel = 99
vim.opt.foldmethod = 'indent'
vim.opt.foldtext = ''

-- Allow cursor to move where there is no text in visual block mode
vim.opt.virtualedit = 'block'

-- Break lines at word boundaries when wrap is enabled
vim.opt.linebreak = true
