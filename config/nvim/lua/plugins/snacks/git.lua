return {
  'snacks.nvim',
  keys = {
    { '<leader>go', function() Snacks.gitbrowse() end, desc = 'Git Browse (Remote)' },
    { '<leader>gb', function() Snacks.picker.git_branches() end, desc = 'Git Branches' },

    { '<leader>g?', function() Snacks.picker.git_log() end, desc = 'Git Log' },
    { '<leader>gL', function() Snacks.picker.git_log_line() end, desc = 'Git Log Line' },

    { '<leader>gs', function() Snacks.picker.git_status() end, desc = 'Git Status' },
    { '<leader>gS', function() Snacks.picker.git_stash() end, desc = 'Git Stash' },
    { '<leader>gd', function() Snacks.picker.git_diff() end, desc = 'Git Diff (Hunks)' },

    { '<leader>gf', function() Snacks.picker.git_log_file() end, desc = 'Git Log File' },

    -- GitHub
    { '<leader>gi', function() Snacks.picker.gh_issue() end, desc = 'GitHub Issues (open)' },
    { '<leader>gI', function() Snacks.picker.gh_issue({ state = 'all' }) end, desc = 'GitHub Issues (all)' },
    { '<leader>gp', function() Snacks.picker.gh_pr() end, desc = 'GitHub Pull Requests (open)' },
    { '<leader>gP', function() Snacks.picker.gh_pr({ state = 'all' }) end, desc = 'GitHub Pull Requests (all)' },
  },
  opts = {

    -- Documentation https://github.com/folke/snacks.nvim/blob/main/docs/git.md
    ---@class snacks.git.Config
    git = {
      enable = true,
    },

    -- Documentation https://github.com/folke/snacks.nvim/blob/main/docs/gh.md
    ---@class snacks.gh.Config
    gh = {
      enable = true,
    },

    -- Documentation https://github.com/folke/snacks.nvim/blob/main/docs/gitbrowse.md
    ---@class snacks.gitbrowse.Config
    gitbrowse = {
      enable = true,
    },

    -- Documentation https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
    ---@class snacks.picker.Config
    picker = {
      layouts = {
        ivy_bottom = {
          layout = {
            auto_hide = { 'input' },
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

      sources = {
        git_log_file = {
          layout = 'ivy_bottom',
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
  },
}
