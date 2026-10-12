local M = {}

M.opts = {
  animate = {},
  bigfile = {},
  health = {},
  image = {},
  input = {},
  quickfile = {},
  scope = {},
  scroll = {},
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
}

function M.keys()
  local map = function(mode, lhs, rhs, opts)
    opts = opts or {}
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  -- Buffer operations
  map('n', '<C-x>', function() Snacks.bufdelete() end, { desc = 'Delete Buffer' })
  map('n', '<leader>cR', function() Snacks.rename.rename_file() end, { desc = 'Rename File' })

  -- Redraw / Clear hlsearch / Diff Update
  map(
    'n',
    '<leader>uR',
    '<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>',
    { desc = 'Redraw / Clear hlsearch / Diff Update' }
  )

  -- Windows
  map('n', '<leader>-', '<C-W>s', { desc = 'Split Window Below', remap = true })
  map('n', '<leader>|', '<C-W>v', { desc = 'Split Window Right', remap = true })
  map('n', '<leader>wd', '<C-W>c', { desc = 'Delete Window', remap = true })

  -- Tabs
  map('n', '<leader><tab>l', '<cmd>tablast<cr>', { desc = 'Last Tab' })
  map('n', '<leader><tab>o', '<cmd>tabonly<cr>', { desc = 'Close Other Tabs' })
  map('n', '<leader><tab>f', '<cmd>tabfirst<cr>', { desc = 'First Tab' })
  map('n', '<leader><tab><tab>', '<cmd>tabnew<cr>', { desc = 'New Tab' })
  map('n', '<leader><tab>]', '<cmd>tabnext<cr>', { desc = 'Next Tab' })
  map('n', '<leader><tab>d', '<cmd>tabclose<cr>', { desc = 'Close Tab' })
  map('n', '<leader><tab>[', '<cmd>tabprevious<cr>', { desc = 'Previous Tab' })

  -- Lua runner
  map({ 'n', 'x' }, '<localleader>r', function() Snacks.debug.run() end, { desc = 'Run Lua' })

  -- Neovim News popup
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
end

return M
