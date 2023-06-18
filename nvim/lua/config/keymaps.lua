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

map(
  "n",
  "<leader>fb",
  "<cmd>Telescope file_browser file_browser previewer=false hidden=true<cr>",
  { noremap = true, desc = "Browse Files" }
)

local M = {}
--Hardtime maps
function M.Hardtime()
  ---@type table?
  local id
  -- for _, key in ipairs({ "h", "j", "k", "l", "+", "-", "<UP>", "<DOWN>", "<LEFT>", "<RIGHT>" }) do
  for _, key in ipairs({ "j", "k" }) do
    local count = 0
    local timer = assert(vim.loop.new_timer())
    vim.keymap.set("n", key, function()
      if vim.v.count > 0 then
        count = 0
      end
      if count >= 5 then
        id = vim.notify("Hold it keyboard warrior!", vim.log.levels.WARN, {
          icon = " ⌨️",
          replace = id,
          keep = function()
            return count >= 10
          end,
        })
      else
        count = count + 1
        timer:start(2000, 0, function()
          count = 0
        end)
        return key
      end
    end, { expr = true, silent = true })
  end
end
M.Hardtime()
