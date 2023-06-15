-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = require("config.util").map

-- Copy Paste Fixes
map("v", "p", "P", { noremap = true, silent = true })
map({ "n", "v" }, "<leader>y", '"+y', { noremap = true, desc = "Copy to OSC52 Clipboard" })
map({ "n", "v" }, "<leader>yy", '"+yy', { noremap = true, desc = "Copy to OSC52 Clipboard" })

-- Blazingly fast way out of insert mode and terminal mode
map("i", "jj", "<esc>")
map("i", "jk", "<esc>")
map("i", "<C-c>", "<esc>")
map("t", "jj", "<C-\\><C-n>")
map("t", "jk", "<C-\\><C-n>")
map("t", "<Esc>", "<C-\\><C-n>", { noremap = true, desc = "Escape Insert Mode" })

-- Beter scrolllssssssss
map("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
map("n", "<C-u>", "<C-u>zz", { desc = " up and center cursor" })
