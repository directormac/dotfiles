local M = {}

local exclude = {
  '**/.secrets/**',
  '**/.secrets',
  '*.age',
  '**/*.age',
  '.git',
  'node_modules',
  '.svelte-kit',
  '.astro',
  '.next',
  '.vercel',
  '.turbo',
  '.expert',
  '.elixir_ls',
  '.vscode',
}

M.opts = {
  picker = {
    sources = {
      files = {
        layout = { hidden = { 'preview' } },
        hidden = true,
        ignored = false,
        exclude = exclude,
      },
      grep = {
        layout = { hidden = { 'preview' } },
        hidden = true,
        ignored = false,
        exclude = exclude,
      },
      buffers = {
        layout = { hidden = { 'preview' } },
        current = false,
      },
      recent = {
        layout = { hidden = { 'preview' } },
      },
      projects = {
        dev = { '~/Projects', '~/Code' },
      },
      zoxide = {},
      man = {},
      notifications = {},
    },
  },
}

-- Plugins picker (<leader>sp) for Nix & lz.n managed plugins
function M.plugins_picker(opts) return require('pickers.lzn-plugins').pick(opts) end

function M.keys()
  local map = function(mode, lhs, rhs, opts)
    opts = opts or {}
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- Pickers (buffers, recent, projects, zoxide, git files)
  map('n', '<leader>,', function() Snacks.picker.buffers() end, { desc = 'Buffers' })
  map('n', '<leader>fb', function() Snacks.picker.buffers() end, { desc = 'Buffers' })
  map('n', '<leader>fr', function() Snacks.picker.recent() end, { desc = 'Recent Files' })
  map('n', '<leader>fp', function() Snacks.picker.projects() end, { desc = 'Projects' })
  map('n', '<leader>fz', function() Snacks.picker.zoxide() end, { desc = 'Zoxide Directories' })
  map('n', '<leader>fg', function() Snacks.picker.git_files() end, { desc = 'Find Git Files' })
  map('n', '<leader>:', function() Snacks.picker.command_history() end, { desc = 'Command History' })

  -- Grep & Search
  map('n', '<leader>sB', function() Snacks.picker.grep_buffers() end, { desc = 'Grep Open Buffers' })
  map('n', '<leader>sP', function() Snacks.picker.pickers() end, { desc = 'All Pickers' })
  map('n', '<leader>s?', function() Snacks.picker.search_history() end, { desc = 'Search History' })
  map('n', '<leader>sn', function() Snacks.picker.notifications() end, { desc = 'Notification History (Picker)' })
  map('n', '<leader>sT', function() Snacks.picker.treesitter() end, { desc = 'Treesitter Symbols' })
  map('n', '<leader>sz', function() Snacks.picker.spelling() end, { desc = 'Spelling Suggestions' })
  map('n', '<leader>s"', function() Snacks.picker.registers() end, { desc = 'Registers' })
  map('n', '<leader>sa', function() Snacks.picker.autocmds() end, { desc = 'Autocmds' })
  map('n', '<leader>sb', function() Snacks.picker.lines() end, { desc = 'Buffer Lines' })
  map('n', '<leader>sC', function() Snacks.picker.commands() end, { desc = 'Commands' })
  map('n', '<leader>sc', function() Snacks.picker.cliphist() end, { desc = 'Clipboard History' })
  map('n', '<leader>sd', function() Snacks.picker.diagnostics() end, { desc = 'Diagnostics' })
  map('n', '<leader>sD', function() Snacks.picker.diagnostics_buffer() end, { desc = 'Buffer Diagnostics' })
  map('n', '<leader>sh', function() Snacks.picker.help() end, { desc = 'Help Pages' })
  map('n', '<leader>sH', function() Snacks.picker.highlights() end, { desc = 'Highlights' })
  map('n', '<leader>si', function() Snacks.picker.icons() end, { desc = 'Icons' })
  map('n', '<leader>sj', function() Snacks.picker.jumps() end, { desc = 'Jumps' })
  map('n', '<leader>sk', function() Snacks.picker.keymaps() end, { desc = 'Keymaps' })
  map('n', '<leader>sl', function() Snacks.picker.loclist() end, { desc = 'Location List' })
  map('n', '<leader>sm', function() Snacks.picker.marks() end, { desc = 'Marks' })
  map('n', '<leader>sM', function() Snacks.picker.man() end, { desc = 'Man Pages' })
  map('n', '<leader>sq', function() Snacks.picker.qflist() end, { desc = 'Quickfix List' })
  map('n', '<leader>sR', function() Snacks.picker.resume() end, { desc = 'Resume' })
  map('n', '<leader>su', function() Snacks.picker.undo() end, { desc = 'Undo History' })
  map('n', '<leader>uC', function() Snacks.picker.colorschemes() end, { desc = 'Colorschemes' })

  -- Custom Plugins picker
  map('n', '<leader>sp', M.plugins_picker, { desc = 'Plugins' })

  -- Todo comments picker
  map('n', '<leader>st', function()
    if not Snacks.picker.sources.todo_comments then
      local ok, todo_snacks = pcall(require, 'todo-comments.snacks')
      if ok and todo_snacks.source then Snacks.picker.sources.todo_comments = todo_snacks.source end
    end
    Snacks.picker.pick('todo_comments', {})
  end, { desc = 'Search Todos' })
end

return M
