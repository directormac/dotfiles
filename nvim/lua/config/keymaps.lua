-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local keymap = vim.keymap

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
-- Clipboard <Leader>y
keymap.set({ "n", "v" }, "<leader>y", '"+y', { desc = "Copy to OSC52 Clipboard" })
keymap.set({ "n", "v" }, "<leader>yy", '"+yy', { desc = "Copy to OSC52 Clipboard" })

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
  require("oil").open_float(cwd)
end, { desc = "Opel Oil Floating" })

keymap.set("n", "<leader>o", "<cmd>AerialToggle!<CR>")

keymap.set(
  "n",
  "<leader>fb",
  ":Telescope file_browser file_browser path=%:p:h=%:p:h<cr>",
  { desc = "Browse Files", noremap = true }
)
