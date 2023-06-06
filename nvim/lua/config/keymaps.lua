-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap
-- local utils = require("utils")
-- Clipboard <Leader>y
keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to OSC52 Clipboard" })
keymap.set({ "n", "v" }, "<leader>yy", '"+yy', { desc = "Copy to OSC52 Clipboard" })



-- Better escape
keymap.set("i", "jj", "<esc>", { noremap = true, desc = "Escape Insert Mode" })
keymap.set("i", "jk", "<esc>", { noremap = true, desc = "Escape Insert Mode" })

keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = " up and center cursor" })

keymap.set("i", "<M-BS>", "<Esc>ciw", { desc = "Alt + Backspace to delete prev word" })
keymap.set("n", "<S-cr>", "ciw", { desc = "Shift+ Enter Change and delete on current word" })

keymap.set("n", "-", require("oil").open, { desc = "Open parent directory" })


-- NeoTree Toggle
-- keymap.set("n", "<leader>o", function()
--   if vim.bo.filetype == "neo-tree" then
--     vim.cmd.wincmd("p")
--   else
--     vim.cmd.Neotree("focus")
--     keymap.set("i", "jj", "<esc>", { desc = "Escape Insert Mode" })
--   end
-- end, { desc = "Toggle Explorer Focus" })


-- save file
-- keymap.set({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<esc>", { desc = "Save file" })

-- keymap.set("x", "<leader>p", [["_dP]], { desc = "No copying on pasted selection" })

-- vim.keymap.set("n", "<leader>bc", function()
--   require("utils").close_all(true)
-- end, { desc = "Close all buffers except current" })

-- vim.api.nvim_set_keymap(
--   "n",
--   "<leader>bo",
--   [[<CMD> lua require('close_buffers').wipe({type = 'other'})]],
--   { noremap = true, silent = true, desc = "Delete Buffers except this." }
-- )
