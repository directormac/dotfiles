return {
  {
    'folke/edgy.nvim',
    event = 'VeryLazy',
    opts = {
      left = {
        {
          title = 'Neo-Tree',
          ft = 'neo-tree',
          filter = function(buf) return vim.b[buf].neo_tree_source == 'filesystem' end,
          pinned = true,
          open = function() vim.api.nvim_input('<esc><space>e') end,
          size = { height = 0.5 },
        },
      },
      right = {
        {
          ft = 'aerial',
          title = 'Symbols',
          size = { width = 0.3 },
          pinned = true,
          open = 'AerialToggle!',
        },
      },
      bottom = {
        {
          title = 'Grug Far',
          ft = 'grug-far',
          size = { height = 0.4 },
        },
        { title = 'Neotest Summary', ft = 'neotest-summary' },
        {
          ft = 'toggleterm',
          size = { height = 0.4 },
          filter = function(buf, win) return vim.api.nvim_win_get_config(win).relative == '' end,
        },
        {
          ft = 'noice',
          size = { height = 0.4 },
          filter = function(buf, win) return vim.api.nvim_win_get_config(win).relative == '' end,
        },
        {
          ft = 'lazyterm',
          title = 'LazyTerm',
          size = { height = 0.4 },
          filter = function(buf) return not vim.b[buf].lazyterm_cmd end,
        },
        'Trouble',
        { ft = 'qf', title = 'QuickFix' },
        {
          ft = 'help',
          size = { height = 20 },
          -- don't open help files in edgy that we're editing
          filter = function(buf) return vim.bo[buf].buftype == 'help' end,
        },
        { title = 'Spectre', ft = 'spectre_panel', size = { height = 0.4 } },
        { title = 'Neotest Output', ft = 'neotest-output-panel', size = { height = 15 } },
      },
    },
  },
}
