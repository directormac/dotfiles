-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
-- local cmd = vim.api.nvim_create_user_command
-- local utils = require("M")
-- local baseevent = utils.event

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

-- autocmd("CursorHold", {
--         buffer = bufnr,
--         callback = function()
--           local float_opts = {
--             focusable = false,
--             close_events = { "BufLeave", "CursorMoved", "InsertEnter", "FocusLost" },
--           }
--
--           if not vim.b.diagnostics_pos then
--             vim.b.diagnostics_pos = { nil, nil }
--           end
--
--           local cursor_pos = vim.api.nvim_win_get_cursor(0)
--           if
--             (cursor_pos[1] ~= vim.b.diagnostics_pos[1] or cursor_pos[2] ~= vim.b.diagnostics_pos[2])
--             and #vim.diagnostic.get() > 0
--           then
--             vim.diagnostic.open_float(nil, float_opts)
--           end
--
--           vim.b.diagnostics_pos = cursor_pos
--         end,
--       })

-- 2. Update buffers when adding new buffers
-- local bufferline_group = augroup("bufferline", { clear = true })
-- autocmd({ "BufAdd", "BufEnter", "TabNewEntered" }, {
--   desc = "Update buffers when adding new buffers",
--   group = bufferline_group,
--   callback = function(args)
--     if not vim.t.bufs then
--       vim.t.bufs = {}
--     end
--     local bufs = vim.t.bufs
--     if not vim.tbl_contains(bufs, args.buf) then
--       table.insert(bufs, args.buf)
--       vim.t.bufs = bufs
--     end
--     vim.t.bufs = vim.tbl_filter(require("base.utils.buffer").is_valid, vim.t.bufs)
--     baseevent("BufsUpdated")
--   end,
-- })
--
-- -- 3. Update buffers when deleting buffers
-- autocmd("BufDelete", {
--   desc = "Update buffers when deleting buffers",
--   group = bufferline_group,
--   callback = function(args)
--     for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
--       local bufs = vim.t[tab].bufs
--       if bufs then
--         for i, bufnr in ipairs(bufs) do
--           if bufnr == args.buf then
--             table.remove(bufs, i)
--             vim.t[tab].bufs = bufs
--             break
--           end
--         end
--       end
--     end
--     vim.t.bufs = vim.tbl_filter(require("base.utils.buffer").is_valid, vim.t.bufs)
--     baseevent("BufsUpdated")
--     vim.cmd.redrawtabline()
--   end,
-- })
--
-- autocmd("BufWinEnter", {
--   desc = "Make q close help, man, quickfix, dap floats",
--   group = augroup("q_close_windows", { clear = true }),
--   callback = function(event)
--     local filetype = vim.api.nvim_get_option_value("filetype", { buf = event.buf })
--     local buftype = vim.api.nvim_get_option_value("buftype", { buf = event.buf })
--     if buftype == "nofile" or filetype == "help" then
--       vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = event.buf, silent = true, nowait = true })
--     end
--   end,
-- })
