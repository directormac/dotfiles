
require('vim._core.ui2').enable({
    enable = true,
    msg = {
        target = "cmd", -- options: cmd(classic), msg(similar to noice)
        pager = { height = 1 },
        msg   = { height = 0.5, timeout = 4500 },
        dialog = { height = 0.5 },
        cmd    = { height = 0.5 },
    },
})

vim.cmd("colorscheme catppuccin")

local global = vim.g
local set = vim.opt
local window = vim.w

global.netrw_banner = 0
global.loaded_netrw = 1 -- Override for oil explorer
global.loaded_netrwPlugin = 1 -- Override for oil explorer

set.tabstop = 2
set.softtabstop = 2
set.shiftwidth = 2
set.expandtab = true
set.smartindent = false
set.wrap = false
set.relativenumber = true
set.signcolumn = "yes"
set.termguicolors = true
set.pumblend = 0
set.pumheight = 0
set.winblend = 0

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function(args)
    require("conform").format({ bufnr = args.buf })
  end,
})

-- indentation
-- vim.opt.tabstop = 4
-- vim.opt.softtabstop = 4
-- vim.opt.shiftwidth = 4
-- vim.opt.expandtab = true
-- vim.opt.smartindent = false
-- vim.opt.wrap = false
--
-- -- backup and undo
-- vim.opt.swapfile = false
-- vim.opt.backup = false
-- vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
-- vim.opt.undofile = true
--
-- -- search
-- vim.opt.inccommand = "split"
--
-- -- UI
-- vim.opt.scrolloff = 8
-- vim.opt.signcolumn = "yes"
--
-- -- folding
-- vim.o.foldenable = true
-- vim.o.foldmethod = "manual"
-- vim.o.foldlevel = 99
-- vim.o.foldcolumn = "0"
--
-- -- window splits
-- vim.opt.splitright = true
-- vim.opt.splitbelow = true
--
-- -- misc
-- vim.opt.guicursor = ""
-- vim.opt.isfname:append("@-@")
-- vim.opt.updatetime = 50
-- vim.opt.colorcolumn = "0"
-- vim.opt.clipboard:append("unnamedplus")
-- vim.opt.mouse = "a"
--
-- -- Hightlight yanking
-- vim.api.nvim_create_autocmd("TextYankPost", {
--     desc = "Highlight when yanking (copying) text",
--     callback = function()
--         vim.hl.on_yank()
--     end,
-- })
