-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
local vim = vim
local vg = vim.g
local vo = vim.opt
local vw = vim.w

-- local is_wsl = (function()
--   local output = vim.fn.systemlist "uname -r"
--   return not not string.find(output[1] or "", "WSL")
-- end)()
--
-- local is_mac = vim.fn.has("macunix") == 1
--
-- local is_linux = not is_wsl and not is_mac

local function copy(lines, _)
  require("osc52").copy(table.concat(lines, "\n"))
end

local function paste()
  return { vim.fn.split(vim.fn.getreg(""), "\n", vim.fn.getregtype("")) }
end
vim.g.clipboard = {
  name = "osc52",
  copy = { ["+"] = copy, ["*"] = copy },
  paste = { ["+"] = paste, ["*"] = paste },
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
vo.list = true

vo.fillchars = {
  fold = " ",
  foldopen = "",
  foldclose = "",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

-- To disable netrw defaulting to Oil
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vg.neoterm_autoinsert = 0 -- Do not start terminal in insert mode
vg.neoterm_autoscroll = 1 -- Autoscroll the terminal

-- Fold options using nvim-ufo
vo.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vo.foldlevelstart = 99
-- vo.foldcolumn = "1" -- Show the fold column
vo.foldenable = true

-- Color Fix for better themes
vo.winblend = 0
vo.pumblend = 0

-- Why not!!!
vo.shortmess = {
  A = true, -- ignore annoying swap file messages
  c = true, -- Do not show completion messages in command line
  F = true, -- Do not show file info when editing a file, in the command line
  I = true, -- Do not show the intro message
  W = true, -- Do not show "written" in command line when writing
}
vo.clipboard = "unnamedplus"
-- vo.cmdheight = 0
vo.showcmd = false
vo.showmatch = true -- Show matching brackets by flickering
vo.showmode = false
vo.splitbelow = true -- Put new windows below current
vo.splitkeep = "screen" -- Default splitting will cause your main splits to jump when opening an edgebar.
vo.splitright = true -- Put new windows right of current
vo.termguicolors = true -- True color support
vo.textwidth = 120 -- Total allowed width on the screen
vo.timeout = true -- This option and 'timeoutlen' determine the behavior when part of a mapped key sequence has been received. This is on by default but being explicit!
vo.timeoutlen = 300 -- Time in milliseconds to wait for a mapped sequence to complete.
vo.updatetime = 100 -- If in this many milliseconds nothing is typed, the swap file will be written to disk. Also used for CursorHold autocommand and set to 100 as per https://github.com/antoinemadec/FixCursorHold.nvim
vo.wildignore = { "*/.git/*", "*/node_modules/*" } -- Ignore these files/folders
vo.wildmode = "list:longest" -- Command-line completion mode
vo.scrolloff = 8
vo.spelllang = { "en" }
vw.colorcolumn = "80,120" -- Make a ruler at 80px and 120px

-- Window optiosn
vw.list = true -- Show some invisible characters like tabs etc
vw.numberwidth = 1 -- Make the line number column thinner
---Note: Setting number and relative number gives you hybrid mode
---https://jeffkreeftmeijer.com/vim-number/
vw.number = true -- Set the absolute number
vw.relativenumber = true -- Set the relative number
vw.signcolumn = "yes" -- Show information next to the line numbers
vw.wrap = false -- Do not display text over multiple lines

-- opt.winbar = "%f -- %{%v:lua.require'nvim-navic'.get_location()%}"
-- vim.o.showcmdloc = "statusline"
-- vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
