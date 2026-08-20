-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

local global = vim.g
local set = vim.opt
local window = vim.w
local Util = require("config.util")

global.loaded_netrw = 1 -- Override for oil explorer
global.loaded_netrwPlugin = 1 -- Override for oil explorer
global.neoterm_autoinsert = 0 -- Do not start terminal in insert mode
global.neoterm_autoscroll = 1 -- Autoscroll the terminal
global.markdown_recommended_style = 0 -- Fix markdown indentation settings
global.lazyvim_prettier_needs_config = true
global.lazyvim_eslint_auto_format = false
-- Motivation: Less clutter in completion windows and a more direct usage of snippets
global.lazyvim_mini_snippets_in_completion = true
global.lazyvim_blink_main = false
-- global.root_spec = { "cwd", "lsp", { ".git", "lua" } }
global.lazyvim_picker = "snacks"
global.lazydev_enabled = true
global.lazyvim_ts_lsp = "vtsls"
-- global.vscode = true

set.clipboard = "unnamedplus"

-- Set shell if windows
-- if jit.os == "Windows" then
--   set.shell = "C:\\Users\\Administrator\\scoop\\apps\\git\\current\\bin\\bash.exe"
-- else
--   global.clipboard = {
-- name = "osc52",
-- copy = { ["+"] = Util.copy, ["*"] = Util.copy },
-- paste = { ["+"] = Util.paste, ["*"] = Util.paste },
-- }
-- set.shell = "/usr/bin/bash"
-- end

-- set.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
set.foldcolumn = "0" -- Show the fold column
set.foldenable = true
set.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
set.foldlevelstart = 99
set.signcolumn = "yes"
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
  c = true, -- Do not show completion messages in command line
  F = true, -- Do not show file info when editing a file, in the command line
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
window.signcolumn = "yes" -- Show information next to the line numbers
window.wrap = false -- Do not display text over multiple lines

if vim.g.neovide then
  -- Put anything you want to happen only in Neovide here
  vim.g.neovide_padding_top = 0
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 0
  vim.g.neovide_padding_left = 0
  vim.g.neovide_transparency = 0.0
  vim.g.transparency = 0.73
  vim.g.neovide_floating_blur_amount_x = 2.0
  vim.g.neovide_floating_blur_amount_y = 2.0
  vim.g.neovide_floating_shadow = true
  vim.g.neovide_floating_z_height = 10
  vim.g.neovide_light_angle_degrees = 45
  vim.g.neovide_light_radius = 5
end

-- vim.diagnostic.config({
--   -- Turn off the cramped side-text entirely
--   virtual_text = false,
--
--   -- Enable native multi-line rendering below the code
--   virtual_lines = true,
--
--   float = {
--     source = "always",
--     border = "rounded",
--   },
--   signs = true,
--   underline = true,
--   update_in_insert = false,
-- })

-- Add this somewhere in your core init or options file
-- vim.diagnostic.config({
--   virtual_text = {
--     -- You can set this to false if you want to completely hide inline text
--     -- and rely entirely on Trouble or floating windows
--     source = "if_many",
--     prefix = "●",
--     -- Truncate long messages in virtual text so they don't break your layout
--     format = function(diagnostic)
--       local first_line = diagnostic.message:match("([^\n]+)")
--       if #first_line > 60 then
--         return string.sub(first_line, 1, 60) .. "..."
--       end
--       return first_line
--     end,
--   },
--   float = {
--     source = "always",
--     border = "rounded",
--     -- This ensures the floating window wraps text to your editor width
--     wrap = true,
--     max_width = math.floor(vim.api.nvim_win_get_width(0) * 0.8),
--   },
--   signs = true,
--   underline = true,
--   update_in_insert = false,
-- })
