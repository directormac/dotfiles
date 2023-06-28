-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = require("config.util").map
local Util = require("lazyvim.util")

-- Copy Paste Fixes
map("v", "p", "P", { noremap = true, silent = true, desc = "Paste content previously yanked" })
map("v", "P", "p", { noremap = true, silent = true, desc = "Yank what you are going to override, then paste" })
map({ "n", "v" }, "<C-x>", '"+y<esc>dd', { noremap = true, desc = "Copy and delete line" })
map({ "n", "v" }, "<C-y>", '"+yy<esc>', { noremap = true, desc = "Copy" })
map({ "n" }, "<C-p>", '"+p<esc>', { noremap = true, desc = "Paste" })
map("v", "x", "_x", { noremap = true, silent = true, desc = "Delete character without yanking" })
map(
  "n",
  "x", -- Also let's allow 'x' key to delete blank lines in normal mode.
  function()
    if vim.fn.col(".") == 1 then
      local line = vim.fn.getline(".")
      if line:match("^%s*$") then
        vim.api.nvim_feedkeys("dd", "n", false)
        vim.api.nvim_feedkeys("$", "n", false)
      else
        vim.api.nvim_feedkeys('"_x', "n", false)
      end
    else
      vim.api.nvim_feedkeys('"_x', "n", false)
    end
  end,
  { noremap = true, silent = true, desc = "Delete character without yanking" }
)

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

-- Tabulation in visual mode
map("v", "<S-Tab>", "<gv", { desc = "Unindent line" })
map("v", "<Tab>", ">gv", { desc = "Indent line" })

-- Code Folding
if Util.has("nvim-ufo") then
  map("n", "zR", function()
    require("ufo").openAllFolds()
  end, { desc = "Open all folds" })
  map("n", "zM", function()
    require("ufo").closeAllFolds()
  end, { desc = "Close all Folds" })
  map("n", "zr", function()
    require("ufo").openFoldsExceptKinds()
  end, { desc = "Fold less" })
  map("n", "zm", function()
    require("ufo").closeFoldsWith()
  end, { desc = "Fold more" })
  map("n", "zv", function()
    require("ufo").peekFoldedLinesUnderCursor()
  end, { desc = "Peek folds" })
end
-- Telescope
--stylua: ignore
map("n", "<leader>fb", "<cmd>Telescope file_browser file_browser previewer=false hidden=true<cr>", { noremap = true, desc = "Browse Files" })
map("n", "<leadeR>fo", require("oil").open, { desc = "Open Oil Explorer" })

-- vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { noremap = true, expr = true, silent = true })
-- vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { noremap = true, expr = true, silent = true })

-- local M = {}
-- --Hardtime maps
-- function M.Hardtime()
--   ---@type table?
--   local id
--   -- for _, key in ipairs({ "h", "j", "k", "l", "+", "-", "<UP>", "<DOWN>", "<LEFT>", "<RIGHT>" }) do
--   for _, key in ipairs({ "j", "k" }) do
--     local count = 0
--     local timer = assert(vim.loop.new_timer())
--     vim.keymap.set("n", key, function()
--       if vim.v.count > 0 then
--         count = 0
--       end
--       if count >= 5 then
--         id = vim.notify("Hold it keyboard warrior!", vim.log.levels.WARN, {
--           icon = " ⌨️",
--           replace = id,
--           keep = function()
--             return count >= 10
--           end,
--         })
--       else
--         count = count + 1
--         timer:start(2000, 0, function()
--           count = 0
--         end)
--         return key
--       end
--     end, { expr = true, silent = true })
--   end
-- end
-- M.Hardtime()
