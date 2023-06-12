-- Install lazy.nvim if not already installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Use a protected call so we don't error out on first use
local ok, lazy = pcall(require, "lazy")
if not ok then
  return
end

-- We have to set the leader key here for lazy.nvim to work
require("helpers.util").set_leader(" ")

local options = {
  colorscheme = "catppuccin",
  install = {
    missing = true,
    colorscheme = { "catppuccin " },
  },
  checker = {
    enabled = true,
    notify = false,
    frequency = 3600,
  },
  change_detection = {
    enabled = true,
    notify = false,
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
}

lazy.setup({ import = "plugins" }, options)

-- Might as well set up an easy-access keybinding

require("helpers.util").map("n", "<leader>L", lazy.show, { desc = "Show Lazy", silent = true })
