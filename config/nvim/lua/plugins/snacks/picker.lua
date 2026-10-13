local Util = require('config.util')
local CommonPickers = require('pickers.common')

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

return {
  'snacks.nvim',
  keys = {
    -- Pickers (buffers, recent, projects, zoxide, git files)
    { '<leader>,', function() Snacks.picker.buffers() end, desc = 'Buffers' },
    { '<leader>fb', function() Snacks.picker.buffers() end, desc = 'Buffers' },
    { '<leader>fr', function() Snacks.picker.recent() end, desc = 'Recent Files' },
    { '<leader>fp', function() Snacks.picker.projects() end, desc = 'Projects' },
    { '<leader>fz', function() Snacks.picker.zoxide() end, desc = 'Zoxide Directories' },
    { '<leader>fg', function() Snacks.picker.git_files() end, desc = 'Find Git Files' },
    { '<leader>:', function() Snacks.picker.command_history() end, desc = 'Command History' },

    -- Grep & Search
    { '<leader>sB', function() Snacks.picker.grep_buffers() end, desc = 'Grep Open Buffers' },
    { '<leader>sP', function() Snacks.picker.pickers() end, desc = 'All Pickers' },
    { '<leader>s?', function() Snacks.picker.search_history() end, desc = 'Search History' },
    { '<leader>sn', function() Snacks.picker.notifications() end, desc = 'Notification History (Picker)' },
    { '<leader>sT', function() Snacks.picker.treesitter() end, desc = 'Treesitter Symbols' },
    { '<leader>sz', function() Snacks.picker.spelling() end, desc = 'Spelling Suggestions' },
    { '<leader>s"', function() Snacks.picker.registers() end, desc = 'Registers' },
    { '<leader>sa', function() Snacks.picker.autocmds() end, desc = 'Autocmds' },
    { '<leader>sb', function() Snacks.picker.lines() end, desc = 'Buffer Lines' },
    { '<leader>sC', function() Snacks.picker.commands() end, desc = 'Commands' },
    { '<leader>sc', function() Snacks.picker.cliphist() end, desc = 'Clipboard History' },
    { '<leader>sd', function() Snacks.picker.diagnostics() end, desc = 'Diagnostics' },
    { '<leader>sD', function() Snacks.picker.diagnostics_buffer() end, desc = 'Buffer Diagnostics' },
    { '<leader>sh', function() Snacks.picker.help() end, desc = 'Help Pages' },
    { '<leader>sH', function() Snacks.picker.highlights() end, desc = 'Highlights' },
    { '<leader>si', function() Snacks.picker.icons() end, desc = 'Icons' },
    { '<leader>sj', function() Snacks.picker.jumps() end, desc = 'Jumps' },
    { '<leader>sk', function() Snacks.picker.keymaps() end, desc = 'Keymaps' },
    { '<leader>sl', function() Snacks.picker.loclist() end, desc = 'Location List' },
    { '<leader>sm', function() Snacks.picker.marks() end, desc = 'Marks' },
    { '<leader>sM', function() Snacks.picker.man() end, desc = 'Man Pages' },
    { '<leader>sq', function() Snacks.picker.qflist() end, desc = 'Quickfix List' },
    { '<leader>sR', function() Snacks.picker.resume() end, desc = 'Resume' },

    -- { '<leader>uC', function() Snacks.picker.colorschemes() end, desc = 'Colorschemes' },

    {
      '<leader>su',
      function()
        Snacks.picker.undo({
          layout = 'ivy_bottom',
        })
      end,
      desc = 'Undo History',
    },

    { '<leader>s`', function() CommonPickers.snippets() end, desc = 'Snippets' },

    -- Custom Plugins picker
    { '<leader>sp', function() require('pickers.lzn-plugins').pick() end, desc = 'Plugins' },

    -- Todo comments picker
    {
      '<leader>st',
      function()
        if not Snacks.picker.sources.todo_comments then
          local ok, todo_snacks = pcall(require, 'todo-comments.snacks')
          if ok and todo_snacks.source then Snacks.picker.sources.todo_comments = todo_snacks.source end
        end
        Snacks.picker.pick('todo_comments', {})
      end,
      desc = 'Search Todos',
    },
  },
  opts = {
    -- Documentation https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
    ---@class snacks.picker.Config
    picker = {
      win = {
        input = {
          keys = {
            ['<a-c>'] = {
              'toggle_cwd',
              mode = { 'n', 'i' },
            },
          },
        },
      },
      actions = {
        ---@param p snacks.Picker
        toggle_cwd = function(p)
          local root = Util.root({ buf = p.input.filter.current_buf, normalize = true })
          local cwd = vim.fs.normalize((vim.uv or vim.loop).cwd() or '.')
          local current = p:cwd()
          p:set_cwd(current == root and cwd or root)
          p:find()
        end,
      },
      ---@class snacks.picker.previewers.Config
      previewers = {
        diff = {
          style = 'fancy',
          cmd = { 'delta' },
          wo = {
            breakindent = true,
            wrap = true,
            linebreak = true,
            showbreak = '',
          },
        },
        git = {
          args = {},
        },
        file = {
          max_size = 1024 * 1024,
          max_line_length = 500,
          ft = nil,
        },
        man_pager = nil,
      },

      --- Layout https://github.com/folke/snacks.nvim/blob/main/docs/picker.md#%EF%B8%8F-layouts
      sources = {
        files = {
          layout = { hidden = { 'preview' } },
          hidden = true,
          ignored = true,
          formatters = { file = { truncate = 100 } },
          exclude = exclude,
        },

        cliphist = {
          finder = 'system_cliphist',
          format = 'text',
          preview = 'preview',
          confirm = { 'copy', 'close' },
          layout = { hidden = { 'preview' } },
        },
        colorschemes = {
          layout = { hidden = { 'preview' } },
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
        keymaps = {
          layout = 'vscode',
        },
        zoxide = {},
        man = {},
      },
    },
  },
}
