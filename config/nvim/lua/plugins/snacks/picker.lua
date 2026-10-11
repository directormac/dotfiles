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
        dev = { '~/projects', '~/.dotfiles' },
      },
      zoxide = {},
      man = {},
      notifications = {},
    },
  },
}

-- Plugins picker (<leader>sp) for Nix & pack plugins
function M.plugins_picker()
  local rtp_names = {}
  for _, path in ipairs(vim.opt.rtp:get()) do
    rtp_names[vim.fs.basename(path)] = true
  end

  local function is_plugin_decl(line, name)
    local escaped = vim.pesc(name)
    return line:match('^%s*[\'"]' .. escaped .. '[\'"]') ~= nil or line:match('{%s*[\'"]' .. escaped .. '[\'"]') ~= nil
  end

  local plugins = nixInfo(nil, 'plugins') or {}
  local config_dir = vim.fn.stdpath('config')
  local spec_files = vim.fn.glob(config_dir .. '/lua/plugins/**/*.lua', false, true)
  local plugin_to_spec = {}

  for _, file in ipairs(spec_files) do
    local lines = vim.fn.readfile(file)
    for lnum, line in ipairs(lines) do
      for name in pairs(plugins.lazy or {}) do
        if not plugin_to_spec[name] and is_plugin_decl(line, name) then
          plugin_to_spec[name] = { file = file, line = lnum }
        end
      end
      for name in pairs(plugins.start or {}) do
        if not plugin_to_spec[name] and is_plugin_decl(line, name) then
          plugin_to_spec[name] = { file = file, line = lnum }
        end
      end
    end
  end

  local items = {}

  for name, path in pairs(plugins.start or {}) do
    local spec_info = plugin_to_spec[name]
    table.insert(items, {
      name = name,
      path = path,
      status = 'start',
      loaded = true,
      text = name .. ' start loaded',
      file = spec_info and spec_info.file or path,
      pos = spec_info and { spec_info.line, 1 } or nil,
      spec_file = spec_info and spec_info.file or nil,
    })
  end

  for name, path in pairs(plugins.lazy or {}) do
    local loaded = rtp_names[name] == true
    local spec_info = plugin_to_spec[name]
    table.insert(items, {
      name = name,
      path = path,
      status = loaded and 'loaded' or 'lazy',
      loaded = loaded,
      text = name .. ' ' .. (loaded and 'loaded' or 'lazy'),
      file = spec_info and spec_info.file or path,
      pos = spec_info and { spec_info.line, 1 } or nil,
      spec_file = spec_info and spec_info.file or nil,
    })
  end

  table.sort(items, function(a, b)
    if a.loaded ~= b.loaded then return a.loaded end
    return a.name < b.name
  end)

  Snacks.picker.pick({
    title = 'Plugins',
    items = items,
    format = function(item, _)
      local icon = item.status == 'start' and '◆ ' or (item.loaded and '● ' or '○ ')
      local icon_hl = item.status == 'start' and 'DiagnosticInfo'
        or (item.loaded and 'DiagnosticOk' or 'DiagnosticWarn')
      local status_label = item.status == 'start' and '[start]' or (item.loaded and '[loaded]' or '[lazy]')
      local status_hl = item.status == 'start' and 'SnacksPickerComment'
        or (item.loaded and 'DiagnosticOk' or 'SnacksPickerComment')

      local ret = {
        { icon, hl = icon_hl },
        { string.format('%-32s', item.name), hl = 'SnacksPickerLabel' },
        { string.format('%-10s', status_label), hl = status_hl },
      }

      if item.spec_file then
        ret[#ret + 1] = { ' ' .. vim.fn.fnamemodify(item.spec_file, ':t'), hl = 'SnacksPickerComment' }
      end

      return ret
    end,
    confirm = function(picker, item)
      picker:close()
      if not item then return end
      if item.spec_file and item.pos then
        vim.cmd.edit(item.spec_file)
        vim.api.nvim_win_set_cursor(0, item.pos)
      elseif item.path then
        Snacks.picker.files({ cwd = item.path, title = item.name .. ' Files' })
      end
    end,
    actions = {
      browse_store = function(picker, item)
        picker:close()
        if item and item.path then Snacks.picker.files({ cwd = item.path, title = item.name .. ' Files' }) end
      end,
      toggle_load = function(picker, item)
        if item and not item.loaded then
          require('lz.n').trigger_load(item.name)
          item.loaded = true
          item.status = 'loaded'
          item.text = item.name .. ' loaded'
          Snacks.notify('Loaded ' .. item.name, { title = 'Plugins' })
          picker:find()
        end
      end,
    },
    win = {
      input = {
        keys = {
          ['<C-o>'] = { 'browse_store', desc = 'Browse store files' },
          ['<C-l>'] = { 'toggle_load', desc = 'Trigger load plugin' },
        },
      },
    },
  })
end

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
