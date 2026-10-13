return {
  'snacks.nvim',
  keys = {

    { '<C-x>', function() Snacks.bufdelete() end, desc = 'Delete Buffer' },
    { '<leader>cR', function() Snacks.rename.rename_file() end, desc = 'Rename File' },
    {
      '<leader>uR',
      '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>',
      desc = 'Redraw / Clear hlsearch / Diff Update',
    },

    { '<leader>-', '<C-W>s', desc = 'Split Window Below', remap = true },
    { '<leader>|', '<C-W>v', desc = 'Split Window Right', remap = true },
    { '<leader>wd', '<C-W>c', desc = 'Delete Window', remap = true },

    -- Tabs
    { '<leader><tab>l', '<cmd>tablast<cr>', desc = 'Last Tab' },
    { '<leader><tab>o', '<cmd>tabonly<cr>', desc = 'Close Other Tabs' },
    { '<leader><tab>f', '<cmd>tabfirst<cr>', desc = 'First Tab' },
    { '<leader><tab><tab>', '<cmd>tabnew<cr>', desc = 'New Tab' },
    { '<leader><tab>]', '<cmd>tabnext<cr>', desc = 'Next Tab' },
    { '<leader><tab>d', '<cmd>tabclose<cr>', desc = 'Close Tab' },
    { '<leader><tab>[', '<cmd>tabprevious<cr>', desc = 'Previous Tab' },

    -- Lua runner
    -- { '<localleader>r', function() Snacks.debug.run() end, desc = 'Run Lua' },

    -- Neovim News popup

    {
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
      desc = 'Neovim News',
    },
  },
  opts = {
    animate = { enable = true },
    bigfile = { enable = true },
    health = { enable = true },
    image = { enable = true },
    input = { enable = true },
    quickfile = { enable = true },
    scope = { enable = true },
    scroll = { enable = true },
    dim = {
      scope = {
        min_size = 5,
        max_size = 20,
        siblings = true,
      },
    },
    zen = {
      toggles = {
        dim = true,
        git_signs = false,
        mini_diff_signs = false,
      },
    },
    statuscolumn = {
      left = { 'mark', 'sign' },
      right = { 'fold', 'git' },
      folds = {
        open = false,
        git_hl = true,
      },
      git = {
        patterns = { 'GitSign', 'MiniDiffSign' },
      },
      refresh = 50,
    },
    styles = {
      float = { backdrop = 60 },
      notification = {
        border = 'single',
      },
    },
  },
}
