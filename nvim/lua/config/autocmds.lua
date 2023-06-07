-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local set_toggle = augroup("set_toggle", { clear = true })

autocmd("InsertEnter", {
  callback = function()
    if vim.bo.filetype ~= "alpha" and vim.bo.filetype ~= "NvimTree" and vim.bo.filetype ~= "SidebarNvim" then
      vim.opt.relativenumber = false
      vim.opt.list = true
    end
  end,
  group = set_toggle,
})

autocmd({ "VimEnter", "BufEnter", "InsertLeave" }, {
  callback = function()
    if vim.bo.filetype ~= "alpha" and vim.bo.filetype ~= "NvimTree" and vim.bo.filetype ~= "SidebarNvim" then
      vim.opt.relativenumber = true
      vim.opt.list = false
    end
  end,
  group = set_toggle,
})

local ts_fold = augroup("ts_fold", { clear = true })

-- autocmd({ "BufReadPost", "FileReadPost" }, {
--   group = ts_fold,
--   pattern = "*",
--   command = "normal zR",
-- })

autocmd({ "BufReadPre", "FileReadPre" }, {
  group = ts_fold,
  pattern = "*",
  command = "normal zR",
})
