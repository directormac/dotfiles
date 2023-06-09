-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap

local function map(mode, lhs, rhs, opts)
  vim.keymap.set(mode, lhs, rhs, opts)
end
map("v", "p", "P", { noremap = true, silent = true })
-- Clipboard <Leader>y
keymap.set({ "n", "v" }, "<leader>y", '"+y', { noremap = true, desc = "Copy to OSC52 Clipboard" })
keymap.set({ "n", "v" }, "<leader>yy", '"+yy', { noremap = true, desc = "Copy to OSC52 Clipboard" })

-- Better escape
keymap.set("i", "jj", "<esc>", { noremap = true, desc = "Escape Insert Mode" })
keymap.set("t", "jj", "<C-\\><C-n>", { noremap = true, desc = "Escape Terminal Mode" })
keymap.set("i", "<C-c>", "<esc>", { noremap = true, desc = "Escape Insert Mode" })
keymap.set("t", "<Esc>", "<C-\\><C-n>", { noremap = true, desc = "Escape Insert Mode" })

keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Scroll down and center cursor" })
keymap.set("n", "<C-u>", "<C-u>zz", { desc = " up and center cursor" })

keymap.set("i", "<M-BS>", "<Esc>ciw", { desc = "Alt + Backspace to delete prev word" })
keymap.set("n", "<S-cr>", "ciw", { desc = "Shift+ Enter Change and delete on current word" })

keymap.set("n", "-", require("oil").open, { desc = "Open Oil File Explorer" })

keymap.set("n", "<Leader>e", function()
  local cwd = require("oil").get_current_dir()
  require("oil").toggle_float(cwd)
end, { desc = "Opel Oil Floating" })

-- keymap.set("n", "<Leader>e", function()
--   require("edgy").toggle("left")
-- end, { desc = "Open Oil Floating" })

keymap.set("n", "<leader>o", "<cmd>AerialToggle!<CR>")
keymap.set("n", "<F1>", "<cmd>Telescope keymaps<cr>", { desc = "Key Maps" })
keymap.set("n", "<F2>", "<cmd>Telescope help_tags<cr>", { desc = "Help Pages" })
keymap.set("n", "<F3>", "<cmd>Telescope man_pages<cr>", { desc = "Manual Pages" })
keymap.set("n", "<F4>", "<cmd>Telescope diagnostics<cr>", { desc = "Workspace Diagnostics" })
keymap.set(
  "n",
  "<leader>fb",
  ":Telescope file_browser file_browser path=%:p:h=%:p:h<cr>",
  { desc = "Browse Files", noremap = true }
)

-- Folding Keymaps refer to nvim-ufo for setup
keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open All Folds" })
keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close All Folds" })
keymap.set("n", "zm", require("ufo").openFoldsExceptKinds, { desc = "Close All Folds" })
keymap.set("n", "zr", require("ufo").closeFoldsWith, { desc = "Close All Folds" })
