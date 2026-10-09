-- snacks.nvim: explorer, pickers, lazygit, terminal, indent guides and statuscolumn.
return {
  {
    'snacks.nvim',
    auto_enable = true,
    -- snacks makes a global, and then lazily loads itself
    lazy = false,
    -- priority only affects startup plugins
    -- unless otherwise specified by a particular handler
    priority = 1000,
    after = function(plugin)
      local function term_nav(dir)
        ---@param self snacks.terminal
        return function(self)
          return self:is_floating() and '<c-' .. dir .. '>' or vim.schedule(function() vim.cmd.wincmd(dir) end)
        end
      end

      ---@type snacks.Config
      require('snacks').setup({
        bigfile = {},
        explorer = { replace_netrw = true },
        git = {},
        gitbrowse = {},
        health = {},
        image = {},
        indent = {},
        input = {},
        notifier = {},
        quickfile = {},
        scope = {},
        scratch = {},
        scroll = {},
        statuscolumn = {
          left = { 'mark', 'sign' }, -- priority of signs on the left (high to low)
          right = { 'fold', 'git' }, -- priority of signs on the right (high to low)
          folds = {
            open = false, -- do not show open fold dots on every line
            git_hl = true, -- use Git Signs hl for fold icons
          },
          git = {
            -- patterns to match Git signs
            patterns = { 'GitSign', 'MiniDiffSign' },
          },
          refresh = 50, -- refresh at most every 50ms
        },
        styles = { float = { backdrop = 60 } },
        terminal = {},
        words = {},

        picker = {
          sources = {
            explorer = {
              auto_close = true,
            },
          },
        },

        dashboard = {

          width = 60,
          pane_gap = 4, -- empty columns between vertical panes
          -- These settings are used by some built-in sections
          preset = {
            ---@type snacks.dashboard.Item[]
            keys = {
              {
                icon = ' ',
                key = 'f',
                desc = 'Find File',
                action = ":lua Snacks.dashboard.pick('files', { layout = { hidden = { 'preview' } } })",
              },
              {
                icon = ' ',
                key = 'g',
                desc = 'Find Text',
                action = ":lua Snacks.dashboard.pick('live_grep', { layout = { hidden = { 'preview' } } })",
              },
              {
                icon = ' ',
                key = 'r',
                desc = 'Recent Files',
                action = ":lua Snacks.dashboard.pick('oldfiles', { layout = { hidden = { 'preview' } } })",
              },
              {
                icon = ' ',
                key = 's',
                desc = 'Restore Session',
                action = function() require('persistence').load() end,
              },
              -- {
              --   icon = '󰚰',
              --   key = 'u',
              --   desc = 'Update Plugins',
              --   -- action = ':lua vim.pack.update()',
              --   action = function() vim.pack.update(nil, { force = true }) end,
              -- },
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
             
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
            function()
              local nix_count = _G.nixInfo
                  and nixInfo.plugins
                  and (vim.tbl_count(nixInfo.plugins.lazy or {}) + vim.tbl_count(nixInfo.plugins.start or {}))
                or 0
              local pack_count = 0
              local lockfile = vim.fs.joinpath(vim.fn.stdpath('config'), 'nvim-pack-lock.json')
              local ok, data = pcall(
                function() return vim.json.decode(table.concat(vim.fn.readfile(lockfile), '\n')) end
              )
              if ok and data and data.plugins then
                pack_count = vim.tbl_count(data.plugins)
              elseif vim.pack and vim.pack.get then
                pack_count = #vim.pack.get()
              end
              local total = nix_count + pack_count
              local ms = _G.__startup_time and string.format('%.2f', (vim.uv.hrtime() - _G.__startup_time) / 1e6) or '0'

              return {
                align = 'center',
                padding = 1,
                text = {
                  { '⚡ Loaded ', hl = 'footer' },
                  { tostring(total), hl = 'special' },
                  { ' plugins (', hl = 'footer' },
                  { tostring(nix_count) .. ' nix', hl = 'Constant' },
                  { ' · ', hl = 'footer' },
                  { tostring(pack_count) .. ' vim.pack', hl = 'Statement' },
                  { ') in ', hl = 'footer' },
                  { ms .. 'ms', hl = 'special' },
                },
              }
            end,
          },
        },
        -- make sure lazygit always reopens the correct program
        -- hopefully this can be removed one day
        lazygit = {
          config = {
            os = {
              editPreset = 'nvim-remote',
              edit = vim.v.progpath
                .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{filename}})<CR>']=],
              editAtLine = vim.v.progpath
                .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{filename}}, {{line}})<CR>']=],
              openDirInEditor = vim.v.progpath
                .. [=[ --server "$NVIM" --remote-send '<cmd>lua nixInfo.lazygit_fix({{dir}})<CR>']=],
              -- this one isnt a remote command, make sure it gets our config regardless of if we name it nvim or not
              editAtLineAndWait = nixInfo(vim.v.progpath, 'progpath') .. ' +{{line}} {{filename}}',
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
      })
      -- Handle the backend of those remote commands.
      -- hopefully this can be removed one day
      nixInfo.lazygit_fix = function(path, line)
        local prev = vim.fn.bufnr('#')
        local prev_win = vim.fn.bufwinid(prev)
        vim.api.nvim_feedkeys('q', 'n', false)
        if line then
          vim.api.nvim_buf_call(prev, function()
            vim.cmd.edit(path)
            local buf = vim.api.nvim_get_current_buf()
            vim.schedule(function()
              if buf then
                vim.api.nvim_win_set_buf(prev_win, buf)
                vim.api.nvim_win_set_cursor(0, { line or 0, 0 })
              end
            end)
          end)
        else
          vim.api.nvim_buf_call(prev, function()
            vim.cmd.edit(path)
            local buf = vim.api.nvim_get_current_buf()
            vim.schedule(function()
              if buf then vim.api.nvim_win_set_buf(prev_win, buf) end
            end)
          end)
        end
      end
      -- NOTE: we aren't loading this lazily, and the keybinds already are so it is fine to just set these here
      -- -- Grep
      -- vim.keymap.set('n', '<leader>sb', function() Snacks.picker.lines() end, { desc = 'Buffer Lines' })
      -- vim.keymap.set('n', '<leader>sB', function() Snacks.picker.grep_buffers() end, { desc = 'Grep Open Buffers' })
      -- vim.keymap.set('n', '<leader>sg', function() Snacks.picker.grep() end, { desc = 'Grep' })
      -- vim.keymap.set(
      --   { 'n', 'x' },
      --   '<leader>sw',
      --   function() Snacks.picker.grep_word() end,
      --   { desc = 'Visual selection or ord' }
      -- )
      -- -- diagnostics
      -- vim.keymap.set('n', '<leader>sd', function() Snacks.picker.diagnostics() end, { desc = 'Diagnostics' })
      -- vim.keymap.set(
      --   'n',
      --   '<leader>sD',
      --   function() Snacks.picker.diagnostics_buffer() end,
      --   { desc = 'Buffer Diagnostics' }
      -- )
      -- vim.keymap.set('n', '<leader>sh', function() Snacks.picker.help() end, { desc = 'Help Pages' })
      -- vim.keymap.set('n', '<leader>sj', function() Snacks.picker.jumps() end, { desc = 'Jumps' })
      -- vim.keymap.set('n', '<leader>sk', function() Snacks.picker.keymaps() end, { desc = 'Keymaps' })
      -- vim.keymap.set('n', '<leader>sl', function() Snacks.picker.loclist() end, { desc = 'Location List' })
      -- vim.keymap.set('n', '<leader>sm', function() Snacks.picker.marks() end, { desc = 'Marks' })
      -- vim.keymap.set('n', '<leader>sM', function() Snacks.picker.man() end, { desc = 'Man Pages' })
      -- vim.keymap.set('n', '<leader>sq', function() Snacks.picker.qflist() end, { desc = 'Quickfix List' })
      -- vim.keymap.set('n', '<leader>sR', function() Snacks.picker.resume() end, { desc = 'Resume' })
      -- vim.keymap.set('n', '<leader>su', function() Snacks.picker.undo() end, { desc = 'Undo History' })

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

      local function map(mode, lhs, rhs, opts)
        opts = opts or {}
        vim.keymap.set(mode, lhs, rhs, opts)
      end

      vim.keymap.set('n', '<leader>e', function() Snacks.explorer.open() end, { desc = 'Snacks file explorer' })
      -- vim.keymap.set('n', '<c-\\>', function() Snacks.terminal.open() end, { desc = 'Snacks Terminal' })

      -- find
      vim.keymap.set('n', '<leader>ff', function() Snacks.picker.files() end, { desc = 'Find Files' })
      vim.keymap.set('n', '<leader>fg', function() Snacks.picker.git_files() end, { desc = 'Find Git Files' })

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
      vim.keymap.set(
        'n',
        '<leader>lN',
        function() Snacks.notifier.show_history() end,
        { desc = 'Notification History' }
      )

      vim.keymap.set('n', '<leader>ln', function() require('noice').cmd('all') end, { desc = 'Noice All' })

      vim.keymap.set('n', '<leader>ur', function()
        vim.cmd('lsp restart')
        vim.notify('LSP restarted', vim.log.levels.INFO, { title = 'LSP' })
      end, { desc = 'Restart Language Server Attached' })

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
      map(
        'n',
        '<leader>gP',
        function() Snacks.picker.gh_pr({ state = 'all' }) end,
        { desc = 'GitHub Pull Requests (all)' }
      )

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
    end,
  },
}
