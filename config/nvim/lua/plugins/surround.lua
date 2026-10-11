return {
  'nvim-surround',
  event = 'DeferredUIEnter',
  keys = {
    { 'gsa', desc = 'Add Surrounding', mode = { 'n', 'x' } },
    { 'gss', desc = 'Add Surrounding to Line', mode = 'n' },
    { 'gsA', desc = 'Add Surrounding (New Line)', mode = { 'n', 'x' } },
    { 'gsd', desc = 'Delete Surrounding', mode = 'n' },
    { 'gsr', desc = 'Replace Surrounding', mode = 'n' },
    { 'gsR', desc = 'Replace Surrounding (New Line)', mode = 'n' },
    { 'ys', desc = 'Add Surrounding', mode = 'n' },
    { 'yss', desc = 'Add Surrounding to Line', mode = 'n' },
    { 'yS', desc = 'Add Surrounding (New Line)', mode = 'n' },
    { 'ds', desc = 'Delete Surrounding', mode = 'n' },
    { 'cs', desc = 'Change Surrounding', mode = 'n' },
  },
  before = function()
    -- Disable nvim-surround default visual mode S to prevent collision with flash.nvim
    vim.g.nvim_surround_no_visual_mappings = true
  end,
  after = function(plugin)
    require('nvim-surround').setup()

    -- LazyVim style surround mappings
    vim.keymap.set('n', 'gsa', '<Plug>(nvim-surround-normal)', { desc = 'Add Surrounding' })
    vim.keymap.set('n', 'gss', '<Plug>(nvim-surround-normal-cur)', { desc = 'Add Surrounding to Line' })
    vim.keymap.set('n', 'gsA', '<Plug>(nvim-surround-normal-line)', { desc = 'Add Surrounding (New Line)' })
    vim.keymap.set('x', 'gsa', '<Plug>(nvim-surround-visual)', { desc = 'Add Surrounding' })
    vim.keymap.set('x', 'gsA', '<Plug>(nvim-surround-visual-line)', { desc = 'Add Surrounding (New Line)' })
    vim.keymap.set('n', 'gsd', '<Plug>(nvim-surround-delete)', { desc = 'Delete Surrounding' })
    vim.keymap.set('n', 'gsr', '<Plug>(nvim-surround-change)', { desc = 'Replace Surrounding' })
    vim.keymap.set('n', 'gsR', '<Plug>(nvim-surround-change-line)', { desc = 'Replace Surrounding (New Line)' })
  end,
}
