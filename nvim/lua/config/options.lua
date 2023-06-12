local vg = vim.g
local vo = vim.opt
local vw = vim.w
local copy = require("helpers.util").copy
local paste = require("helpers.util").paste

vg.clipboard = {
  name = "osc52",
  copy = { ["+"] = copy, ["*"] = copy },
  paste = { ["+"] = paste, ["*"] = paste },
}

vg.loaded_netrw = 1 -- Override for oil explorer
vg.loaded_netrwPlugin = 1 -- Override for oil explorer
vg.neoterm_autoinsert = 0 -- Do not start terminal in insert mode
vg.neoterm_autoscroll = 1 -- Autoscroll the terminal
vg.markdown_recommended_style = 0 -- Fix markdown indentation settings
vo.autowrite = true -- Enable autowrite
vo.clipboard = "unnamedplus" -- Sync with system clipboard
-- vo.completeopt = "menu,menuone,noselect"
vo.conceallevel = 3 -- Hide * markup for bold and italic
vo.confirm = true -- Confirm save changes before exiting modified buffer
vo.cmdheight = 0 -- We got lualine now no need for it
vo.cursorline = true -- Enable highlighting of the current line
vo.formatoptions = "jcroqlnt" -- tcqj
vo.grepformat = "%f:%l:%c:%m"
vo.grepprg = "rg --vimgrep"
vo.ignorecase = true -- Ignore case
vo.inccommand = "nosplit"
vo.laststatus = 0
vo.expandtab = true
vo.foldcolumn = "0" -- Show the fold column
vo.foldenable = true
vo.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vo.foldlevelstart = 99
vo.list = true
vo.number = true
vo.mouse = "a" -- Enable Mouse
vo.pumblend = 0
vo.pumheight = 0
vo.relativenumber = true
vo.scrolloff = 4 -- Lines of context
vo.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "globals" }
vo.shiftround = true -- Round indent
vo.shiftwidth = 2
vo.showcmd = false
vo.showmatch = true -- Show matching brackets by flickering
vo.showmode = false -- No need we got status line
vo.showtabline = 2 -- For tabby
vo.sidescrolloff = 8 -- Columns of context
vo.signcolumn = "yes" -- Always show signcolumn
vo.smartcase = true -- Dont ignore case with capitals
vo.smartindent = true
vo.spelllang = { "en" }
vo.splitbelow = true -- Put new windows below current
vo.splitkeep = "screen" -- Default splitting will cause your main splits to jump when opening an edgebar.
vo.splitright = true -- Put new windows right of current
vo.tabstop = 2
vo.termguicolors = true -- True color support
vo.textwidth = 120 -- Total allowed width on the screen
vo.timeout = true -- This option and 'timeoutlen' determine the behavior when part of a mapped key sequence has been received. This is on by default but being explicit!
vo.timeoutlen = 300 -- Time in milliseconds to wait for a mapped sequence to complete.
vo.undofile = true
vo.undolevels = 10000
vo.updatetime = 100 -- If in this many milliseconds nothing is typed, the swap file will be written to disk. Also used for CursorHold autocommand and set to 100 as per https://github.com/antoinemadec/FixCursorHold.nvim
vo.wildignore = { "*/.git/*", "*/node_modules/*" } -- Ignore these files/folders
vo.wildmode = "list:longest" -- Command-line completion mode
vo.winblend = 0
vo.winminwidth = 5
vo.wrap = false
vo.fillchars = {
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}
vo.listchars = {
  space = ".",
  eol = "↲",
  nbsp = "␣",
  trail = "·",
  precedes = "←",
  extends = "→",
  tab = "¬ ",
  conceal = "※",
}

vo.shortmess = {
  A = true, -- ignore annoying swap file messages
  c = true, -- Do not show completion messages in command line
  F = true, -- Do not show file info when editing a file, in the command line
  I = true, -- Do not show the intro message
  W = true, -- Do not show "written" in command line when writing
}

-- Window optiosn
vw.list = true -- Show some invisible characters like tabs etc
vw.numberwidth = 1 -- Make the line number column thinner
---Note: Setting number and relative number gives you hybrid mode
---https://jeffkreeftmeijer.com/vim-number/
vw.number = true -- Set the absolute number
vw.relativenumber = true -- Set the relative number
vw.signcolumn = "yes" -- Show information next to the line numbers
vw.wrap = false -- Do not display text over multiple lines
-- Set other options
local colorscheme = require("helpers.colorscheme")
vim.cmd.colorscheme(colorscheme)
