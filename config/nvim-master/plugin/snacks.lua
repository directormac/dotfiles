-- vim.pack.add({ 'https://github.com/folke/snacks.nvim' })

-- Reference for styling
-- https://github.com/folke/snacks.nvim/blob/main/docs/styles.md

-- INIT BLOCK
vim.g.snacks_animate = false

local M = {}

---@param opts? snacks.picker.Config
function M.neovim_logs(opts)
  local log_dir = vim.fn.stdpath('log')
  if vim.fn.isdirectory(log_dir) == 0 then
    vim.notify('Neovim log directory not found at: ' .. log_dir, vim.log.levels.WARN)
    return
  end

  return Snacks.picker.files(vim.tbl_deep_extend('keep', opts or {}, {
    title = 'Neovim Log Files',
    cwd = log_dir,
    confirm = function(picker, item)
      local selected = picker:selected({ fallback = true })
      picker:close()
      for i, selected_item in ipairs(selected) do
        local full_path = picker:cwd() .. '/' .. selected_item.file
        if i == 1 then
          vim.cmd('split ' .. vim.fn.fnameescape(full_path))
        else
          vim.cmd('vsplit ' .. vim.fn.fnameescape(full_path))
        end
        vim.cmd('set ft=log')
        vim.cmd('normal! G')
      end
    end,
  }))
end

Snacks.notify('Snacks booting up. . . ')

-- Count plugins from vim.pack lockfile
local function plugin_count()
  local lockfile = vim.fs.joinpath(vim.fn.stdpath('config'), 'nvim-pack-lock.json')
  local ok, data = pcall(function() return vim.json.decode(table.concat(vim.fn.readfile(lockfile), '\n')) end)
  if ok and data and data.plugins then return vim.tbl_count(data.plugins) end
  return 0
end

-- ===========
-- Terminal Configuration

---@type snacks.terminal.Opts
local terminal = {}

require('pack')

local function term_nav(dir)
  ---@param self snacks.terminal
  return function(self)
    return self:is_floating() and '<c-' .. dir .. '>' or vim.schedule(function() vim.cmd.wincmd(dir) end)
  end
end

---@type snacks.dashboard.Config
local customDashboard = {
  enabled = true,
  width = 60,
  pane_gap = 4, -- empty columns between vertical panes
  -- These settings are used by some built-in sections
  preset = {
    ---@type snacks.dashboard.Item[]
    keys = {
      { icon = ' ', key = 'f', desc = 'Find File', action = ":lua Snacks.dashboard.pick('files')" },
      { icon = ' ', key = 'g', desc = 'Find Text', action = ":lua Snacks.dashboard.pick('live_grep')" },
      { icon = ' ', key = 'r', desc = 'Recent Files', action = ":lua Snacks.dashboard.pick('oldfiles')" },
      {
        icon = ' ',
        key = 's',
        desc = 'Restore Session',
        action = function() require('persistence').load() end,
      },
      {
        icon = '󰚰',
        key = 'u',
        desc = 'Update Plugins',
        -- action = ':lua vim.pack.update()',
        action = function() vim.pack.update(nil, { force = true }) end,
      },
      { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
    },

    -- Used by the `header` section
    header = [[
   █████╗ ██████╗ ████████╗██╗███████╗███████╗██╗  ██╗
  ██╔══██╗██╔══██╗╚══██╔══╝██║██╔════╝██╔════╝╚██╗██╔╝
  ███████║██████╔╝   ██║   ██║█████╗  █████╗   ╚███╔╝
  ██╔══██║██╔══██╗   ██║   ██║██╔══╝  ██╔══╝   ██╔██╗
  ██║  ██║██║  ██║   ██║   ██║██║     ███████╗██╔╝╚██╗
  ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝╚═╝     ╚══════╝╚═╝  ╚═╝
  ɔɐɯɹoʇɔǝɹᴉp
           
        ]],
  },
  -- item field formatters
  formats = {
    icon = function(item)
      if item.file and item.icon == 'file' or item.icon == 'directory' then
        return Snacks.dashboard.icon(item.file, item.icon)
      end
      return { item.icon, width = 2, hl = 'icon' }
    end,
    footer = { '%s', align = 'center' },
    header = { '%s', align = 'center' },
    file = function(item, ctx)
      local fname = vim.fn.fnamemodify(item.file, ':~')
      fname = ctx.width and #fname > ctx.width and vim.fn.pathshorten(fname) or fname
      if #fname > ctx.width then
        local dir = vim.fn.fnamemodify(fname, ':h')
        local file = vim.fn.fnamemodify(fname, ':t')
        if dir and file then
          file = file:sub(-(ctx.width - #dir - 2))
          fname = dir .. '/…' .. file
        end
      end
      local dir, file = fname:match('^(.*)/(.+)$')
      return dir and { { dir .. '/', hl = 'dir' }, { file, hl = 'file' } } or { { fname, hl = 'file' } }
    end,
  },
  ---@type snacks.dashboard.Section
  sections = {
    { section = 'header' },
    { section = 'keys', gap = 1, padding = 1 },
    {
      align = 'center',
      padding = 1,
      text = {
        {
          '󱐋 Loaded ' .. tostring(plugin_count()) .. ' plugins via vim.pack',
          hl = 'footer',
        },
      },
    },
  },
  win = {
    keys = {
      nav_h = { '<C-h>', term_nav('h'), desc = 'Go to Left Window', expr = true, mode = 't' },
      nav_j = { '<C-j>', term_nav('j'), desc = 'Go to Lower Window', expr = true, mode = 't' },
      nav_k = { '<C-k>', term_nav('k'), desc = 'Go to Upper Window', expr = true, mode = 't' },
      nav_l = { '<C-l>', term_nav('l'), desc = 'Go to Right Window', expr = true, mode = 't' },
      hide_slash = { '<C-/>', 'hide', desc = 'Hide Terminal', mode = 't' },
      hide_underscore = { '<c-_>', 'hide', desc = 'which_key_ignore', mode = 't' },
    },
  },
}

---@type snacks.Config
require('snacks').setup({
  input = { enabled = true },
  bigfile = { enabled = true },
  dashboard = customDashboard,
  explorer = { enabled = true },
  git = { enabled = true },
  gitbrowse = { enabled = true },
  health = { enabled = true },
  image = { enabled = false, inline = false },
  indent = { enabled = true },
  lazygit = { enabled = true },
  notifier = { enabled = true },
  quickfile = { enabled = true },
  scope = { enabled = true },
  scratch = { enabled = true },
  scroll = { enabled = true },
  statuscolumn = { enabled = true },
  styles = { float = { backdrop = 60 } },
  words = { enabled = true },
  picker = { enabled = true },
  terminal = terminal,
})

-- Setup some globals for debugging (lazy-loaded)
_G.dd = function(...) Snacks.debug.inspect(...) end
_G.bt = function() Snacks.debug.backtrace() end

-- Create some toggle mappings
Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map('<leader>uL')
Snacks.toggle.diagnostics():map('<leader>ud')
Snacks.toggle.line_number():map('<leader>ul')
Snacks.toggle
  .option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
  :map('<leader>uc')
Snacks.toggle.treesitter():map('<leader>uT')
Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map('<leader>ub')
Snacks.toggle.inlay_hints():map('<leader>uh')
Snacks.toggle.indent():map('<leader>ug')
Snacks.toggle.dim():map('<leader>uD')

Snacks.toggle.profiler():map('<leader>dpp')
Snacks.toggle.profiler_highlights():map('<leader>dph')

Snacks.toggle.zoom():map('<leader>wm'):map('<leader>uZ')
Snacks.toggle.zen():map('<leader>uz')

-- map('n', '<leader>uz', function() Snacks.zen() end, { desc = 'Toggle Zen Mode' })
-- map('n', '<leader>uZ', function() Snacks.zen.zoom() end, { desc = 'Toggle Zoom' })

vim.keymap.set('n', '<leader>ur', function()
  vim.cmd('lsp restart')
  vim.notify('LSP restarted', vim.log.levels.INFO, { title = 'LSP' })
end, { desc = 'Restart Language Server Attached' })

-- KEYS BLOCK
local function map(mode, lhs, rhs, opts)
  opts = opts or {}
  vim.keymap.set(mode, lhs, rhs, opts)
end

local exclude = {
  '**/node_modules',
}

vim.keymap.set('n', '<leader><leader>', function()
  Snacks.picker.smart({
    title = 'Smart File Picker',
    header = 'Hello',
    -- prompt = '',

    layout = { hidden = { 'preview' } },
    multi = { 'recent', 'files' },
    hidden = true,
    ignored = true,
    formatters = { file = { truncate = 100 } },
  })
end, { desc = 'Smart file picker.' })

vim.keymap.set(
  'n',
  '<leader>/',
  function()
    Snacks.picker.grep({
      layout = { hidden = { 'preview' } },
      hidden = true,
      ignored = true,
      formatters = { file = { truncate = 100 } },
    })
  end,
  { desc = 'Smart file picker.' }
)

vim.keymap.set('n', '<leader>:', function() Snacks.picker.command_history() end, { desc = 'Command History' })

vim.keymap.set('n', '<leader>?', function() Snacks.picker.search_history() end, { desc = 'Search History' })

vim.keymap.set('n', '<leader>.', function() Snacks.scratch() end, { desc = 'Toggle Scratch Buffer' })

-- Logs
vim.keymap.set('n', '<leader>ls', function() Snacks.picker.search_history() end, { desc = 'Search History' })
vim.keymap.set('n', '<leader>lc', function() Snacks.picker.command_history() end, { desc = 'Command History' })
vim.keymap.set('n', '<leader>lN', function() Snacks.notifier.show_history() end, { desc = 'Notification History' })
vim.keymap.set('n', '<leader>lna', function() require('noice').cmd('all') end, { desc = 'Noice All' })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
  'n',
  '<leader>uR',
  '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>',
  { desc = 'Redraw / Clear hlsearch / Diff Update' }
)

-- windows
map('n', '<leader>-', '<C-W>s', { desc = 'Split Window Below', remap = true })
map('n', '<leader>|', '<C-W>v', { desc = 'Split Window Right', remap = true })
map('n', '<leader>wd', '<C-W>c', { desc = 'Delete Window', remap = true })

-- tabs
map('n', '<leader><tab>l', '<cmd>tablast<cr>', { desc = 'Last Tab' })
map('n', '<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Close Other Tabs' })
map('n', '<leader><tab>f', '<cmd>tabfirst<cr>', { desc = 'First Tab' })
map('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = 'New Tab' })
map('n', '<leader><tab>]', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
map('n', '<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Close Tab' })
map('n', '<leader><tab>[', '<cmd>tabprevious<cr>', { desc = 'Previous Tab' })

-- lua
map({ 'n', 'x' }, '<localleader>r', function() Snacks.debug.run() end, { desc = 'Run Lua' })

-- git
map('n', '<leader>gb', function() Snacks.picker.git_branches() end, { desc = 'Git Branches' })
map('n', '<leader>gl', function() Snacks.picker.git_log() end, { desc = 'Git Log' })
map('n', '<leader>gL', function() Snacks.picker.git_log_line() end, { desc = 'Git Log Line' })
map('n', '<leader>gs', function() Snacks.picker.git_status() end, { desc = 'Git Status' })
map('n', '<leader>gS', function() Snacks.picker.git_stash() end, { desc = 'Git Stash' })
map('n', '<leader>gd', function() Snacks.picker.git_diff() end, { desc = 'Git Diff (Hunks)' })
map('n', '<leader>gf', function() Snacks.picker.git_log_file() end, { desc = 'Git Log File' }) -- Grep
map('n', '<leader>sb', function() Snacks.picker.lines() end, { desc = 'Buffer Lines' })
map('n', '<leader>sB', function() Snacks.picker.grep_buffers() end, { desc = 'Grep Open Buffers' })
map('n', '<leader>sg', function() Snacks.picker.grep() end, { desc = 'Grep' })
map({ 'n', 'x' }, '<leader>sw', function() Snacks.picker.grep_word() end, { desc = 'Visual selection or word' })
map('n', '<leader>gi', function() Snacks.picker.gh_issue() end, { desc = 'GitHub Issues (open)' })
map('n', '<leader>gI', function() Snacks.picker.gh_issue({ state = 'all' }) end, { desc = 'GitHub Issues (all)' })
map('n', '<leader>gp', function() Snacks.picker.gh_pr() end, { desc = 'GitHub Pull Requests (open)' })
map('n', '<leader>gP', function() Snacks.picker.gh_pr({ state = 'all' }) end, { desc = 'GitHub Pull Requests (all)' })

-- search
map('n', '<leader>s"', function() Snacks.picker.registers() end, { desc = 'Registers' })

vim.keymap.set('n', '<leader>s.', function() Snacks.scratch.select() end, { desc = 'Select Scratch Buffer' })

map('n', '<leader>sa', function() Snacks.picker.autocmds() end, { desc = 'Autocmds' })
map('n', '<leader>sb', function() Snacks.picker.lines() end, { desc = 'Buffer Lines' })
map('n', '<leader>sC', function() Snacks.picker.commands() end, { desc = 'Commands' })
map('n', '<leader>sc', function() Snacks.picker.cliphist() end, { desc = 'Commands' })
map('n', '<leader>sd', function() Snacks.picker.diagnostics() end, { desc = 'Diagnostics' })
map('n', '<leader>sD', function() Snacks.picker.diagnostics_buffer() end, { desc = 'Buffer Diagnostics' })
map('n', '<leader>sh', function() Snacks.picker.help() end, { desc = 'Help Pages' })
map('n', '<leader>sH', function() Snacks.picker.highlights() end, { desc = 'Highlights' })
map('n', '<leader>si', function() Snacks.picker.icons() end, { desc = 'Icons' })
map('n', '<leader>sj', function() Snacks.picker.jumps() end, { desc = 'Jumps' })
map('n', '<leader>sk', function() Snacks.picker.keymaps() end, { desc = 'Keymaps' })
map('n', '<leader>sl', function() Snacks.picker.loclist() end, { desc = 'Location List' })
map('n', '<leader>sm', function() Snacks.picker.marks() end, { desc = 'Marks' })
map('n', '<leader>sM', function() Snacks.picker.man(require('')) end, { desc = 'Man Pages' })
map('n', '<leader>sp', function() Snacks.picker.lazy() end, { desc = 'Search for Plugin Spec' })
map('n', '<leader>sq', function() Snacks.picker.qflist() end, { desc = 'Quickfix List' })
map('n', '<leader>sR', function() Snacks.picker.resume() end, { desc = 'Resume' })
map('n', '<leader>su', function() Snacks.picker.undo() end, { desc = 'Undo History' })
map('n', '<leader>uC', function() Snacks.picker.colorschemes() end, { desc = 'Colorschemes' })

-- Todo comments picker
map('n', '<leader>st', function()
  -- Lazy register todo-comments source if not already registered
  if not Snacks.picker.sources.todo_comments then
    local ok, todo_snacks = pcall(require, 'todo-comments.snacks')
    if ok and todo_snacks.source then Snacks.picker.sources.todo_comments = todo_snacks.source end
  end
  Snacks.picker.pick('todo_comments', {})
end, { desc = 'Search Todos' })

map('n', '<leader>bd', function() Snacks.bufdelete() end, { desc = 'Delete Buffer' })
map('n', '<C-x>', function() Snacks.bufdelete() end, { desc = 'Delete Buffer' })
map('n', '<leader>cR', function() Snacks.rename.rename_file() end, { desc = 'Rename File' })
map({ 'n', 'v' }, '<leader>gB', function() Snacks.gitbrowse() end, { desc = 'Git Browse' })
map('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Lazygit' })
map('n', '<leader>un', function() Snacks.notifier.hide() end, { desc = 'Dismiss All Notifications' })

map('n', '<c-/>', function() Snacks.terminal() end, { desc = 'Toggle Terminal' })
map('n', '<c-_>', function() Snacks.terminal() end, { desc = 'which_key_ignore' })

map({ 'n', 't' }, ']]', function() Snacks.words.jump(vim.v.count1) end, { desc = 'Next Reference' })
map({ 'n', 't' }, '[[', function() Snacks.words.jump(-vim.v.count1) end, { desc = 'Prev Reference' })

map(
  'n',
  '<leader>oN',
  function()
    Snacks.win({
      file = vim.api.nvim_get_runtime_file('doc/news.txt', false)[1],
      width = 0.6,
      height = 0.6,
      wo = {
        spell = false,
        wrap = false,
        signcolumn = 'yes',
        statuscolumn = ' ',
        conceallevel = 3,
      },
    })
  end,
  { desc = 'Neovim News' }
)
