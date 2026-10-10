-- Runtime plugin script: sourced automatically from 'runtimepath' after init.lua.
-- Editor-level globals and autocmds that do not depend on any plugin.

-- [[ Disable auto comment on enter ]]
-- See :help formatoptions
vim.api.nvim_create_autocmd('FileType', {
  desc = 'remove formatoptions',
  callback = function() vim.opt.formatoptions:remove({ 'c', 'r', 'o' }) end,
})

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function() vim.highlight.on_yank() end,
  group = highlight_group,
  pattern = '*',
})

vim.api.nvim_create_autocmd(
  'FileType',
  { callback = function() vim.cmd('setlocal formatoptions-=c formatoptions-=o') end, desc = 'Proper formatoptions' }
)

-- Auto-reload files changed outside of Neovim when Neovim gains focus
local _checktime_timer = nil
vim.api.nvim_create_autocmd({ 'FocusGained', 'TermClose', 'TermLeave' }, {
  group = vim.api.nvim_create_augroup('auto_checktime', { clear = true }),
  callback = function()
    if _checktime_timer then
      _checktime_timer:stop()
      _checktime_timer:close()
      _checktime_timer = nil
    end
    _checktime_timer = vim.defer_fn(function()
      _checktime_timer = nil
      if vim.o.buftype ~= 'nofile' then vim.cmd('checktime') end
    end, 200)
  end,
})

-- Automatically resize splits when the host window is resized
local _resize_timer = nil
vim.api.nvim_create_autocmd({ 'VimResized' }, {
  group = vim.api.nvim_create_augroup('auto_resize_splits', { clear = true }),
  callback = function()
    if _resize_timer then
      _resize_timer:stop()
      _resize_timer:close()
      _resize_timer = nil
    end
    local current_tab = vim.fn.tabpagenr()
    _resize_timer = vim.defer_fn(function()
      _resize_timer = nil
      vim.cmd('tabdo wincmd =')
      vim.cmd('tabnext ' .. current_tab)
    end, 100)
  end,
})

-- Go to the last cursor location when opening a buffer
vim.api.nvim_create_autocmd('BufReadPost', {
  group = vim.api.nvim_create_augroup('auto_last_loc', { clear = true }),
  callback = function(event)
    local exclude = { 'gitcommit' }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then return end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})

-- Close some utility filetypes with <q>
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('auto_close_with_q', { clear = true }),
  pattern = {
    'help',
    'lspinfo',
    'notify',
    'qf',
    'startuptime',
    'checkhealth',
    'grug-far',
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.schedule(function()
      vim.keymap.set('n', 'q', function()
        local ok = pcall(vim.cmd.close)
        if not ok then pcall(vim.api.nvim_buf_delete, event.buf, { force = true }) end
      end, { buffer = event.buf, silent = true, desc = 'Quit buffer' })
    end)
  end,
})

-- Auto create dir when saving a file, in case intermediate directory does not exist
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
  group = vim.api.nvim_create_augroup('auto_create_dir', { clear = true }),
  callback = function(event)
    if event.match:match('^%w%w+:[\\/][\\/]') then return end
    local file = vim.uv.fs_realpath(event.match) or event.match
    vim.fn.mkdir(vim.fn.fnamemodify(file, ':p:h'), 'p')
  end,
})

-- Disable UI clutter in Insert mode for performance
local insert_ui_perf = vim.api.nvim_create_augroup('insert_ui_perf', { clear = true })
vim.api.nvim_create_autocmd('InsertEnter', {
  group = insert_ui_perf,
  callback = function()
    vim.wo.cursorline = false
    vim.wo.relativenumber = false
    vim.wo.number = true
  end,
})
vim.api.nvim_create_autocmd('InsertLeave', {
  group = insert_ui_perf,
  callback = function()
    vim.wo.cursorline = true
    vim.wo.relativenumber = true
  end,
})

-- Enable line wrapping for text/markdown files
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('wrap_spell', { clear = true }),
  pattern = { 'text', 'plaintex', 'typst', 'gitcommit', 'markdown' },
  callback = function() vim.opt_local.wrap = true end,
})

-- Consider hyphens as part of a word for CSS/HTML/JS
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('iskeyword_kebab', { clear = true }),
  pattern = { 'css', 'scss', 'less', 'html', 'htmldjango', 'blade', 'typescriptreact', 'javascriptreact' },
  callback = function() vim.opt_local.iskeyword:append('-') end,
})

-- Fix conceallevel for JSON files
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('json_conceal', { clear = true }),
  pattern = { 'json', 'jsonc', 'json5' },
  callback = function() vim.opt_local.conceallevel = 0 end,
})
