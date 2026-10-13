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
        -- fancy: Snacks fancy diff (borders, multi-column line numbers, syntax highlighting)
        -- syntax: Neovim's built-in diff syntax highlighting
        -- terminal: external command (git's pager for git commands, `cmd` for other diffs)
        style = 'fancy', ---@type "fancy"|"syntax"|"terminal"
        cmd = { 'delta' }, -- example for using `delta` as the external diff command
        ---@type vim.wo?|{} window options for the fancy diff preview window
        wo = {
          breakindent = true,
          wrap = true,
          linebreak = true,
          showbreak = '',
        },
      },
      git = {
        args = {}, -- additional arguments passed to the git command. Useful to set pager options usin `-c ...`
      },
      file = {
        max_size = 1024 * 1024, -- 1MB
        max_line_length = 500, -- max line length
        ft = nil, ---@type string? filetype for highlighting. Use `nil` for auto detect
      },
      man_pager = nil, ---@type string? MANPAGER env to use for `man` preview
    },

    layouts = {
      ivy_bottom = {
        auto_hide = { 'input' },
        layout = {
          box = 'vertical',
          backdrop = false,
          row = -1,
          width = 0,
          height = 0.4,
          border = 'top',
          title = ' {title} {live} {flags}',
          title_pos = 'left',
          { win = 'input', height = 1, border = 'bottom' },
          {
            box = 'horizontal',
            { win = 'list', border = 'none' },
            { win = 'preview', title = '{preview}', width = 0.8, border = 'left' },
          },
        },
      },
    },

    --- Layout https://github.com/folke/snacks.nvim/blob/main/docs/picker.md#%EF%B8%8F-layouts
    sources = {
      files = {
        layout = { hidden = { 'preview' } },
        -- multi = { 'recent', 'files' },
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
      zoxide = {},
      man = {},

      -- Git

      git_log_file = {
        layout = 'vscode',
      },

      git_log_line = {
        layout = 'ivy_bottom',
      },

      git_branches = {
        layout = 'ivy_bottom',
      },

      git_diff = {
        group = false,
        finder = 'git_diff',
        format = 'git_status',
        preview = 'diff',
        matcher = { sort_empty = true },
        sort = { fields = { 'score:desc', 'file', 'idx' } },
        win = {
          input = {
            keys = {
              ['<Tab>'] = { 'git_stage', mode = { 'n', 'i' } },
              ['<c-r>'] = { 'git_restore', mode = { 'n', 'i' }, nowait = true },
            },
          },
        },

        layout = 'ivy_bottom',
      },

      git_log = {
        layout = 'ivy_bottom',
      },
    },
  },

  git = {
    enable = true,
  },
  gh = {
    enable = true,
  },
  gitbrowse = {
    enable = true,
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

  -- Git

  map({ 'n', 'v' }, '<leader>go', function() Snacks.gitbrowse() end, { desc = 'Git Browse (Remote)' })
  map('n', '<leader>gb', function() Snacks.picker.git_branches() end, { desc = 'Git Branches' })

  map('n', '<leader>g?', function() Snacks.picker.git_log() end, { desc = 'Git Log' })
  map('n', '<leader>gL', function() Snacks.picker.git_log_line() end, { desc = 'Git Log Line' })

  map('n', '<leader>gs', function() Snacks.picker.git_status() end, { desc = 'Git Status' })
  map('n', '<leader>gS', function() Snacks.picker.git_stash() end, { desc = 'Git Stash' })
  map('n', '<leader>gd', function() Snacks.picker.git_diff() end, { desc = 'Git Diff (Hunks)' })

  map('n', '<leader>gf', function() Snacks.picker.git_log_file() end, { desc = 'Git Log File' })

  -- GitHub
  map('n', '<leader>gi', function() Snacks.picker.gh_issue() end, { desc = 'GitHub Issues (open)' })
  map('n', '<leader>gI', function() Snacks.picker.gh_issue({ state = 'all' }) end, { desc = 'GitHub Issues (all)' })
  map('n', '<leader>gp', function() Snacks.picker.gh_pr() end, { desc = 'GitHub Pull Requests (open)' })
  map('n', '<leader>gP', function() Snacks.picker.gh_pr({ state = 'all' }) end, { desc = 'GitHub Pull Requests (all)' })
end

return M
