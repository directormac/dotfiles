-- Markdown filetype settings. Sourced automatically on FileType=markdown.

-- Prose should not be wrapped at the window edge.
vim.opt_local.wrap = false

vim.opt_local.spell = true

-- Toggle the two checked listbox markers with `[[` and `]]`.
vim.keymap.set(
  { 'n', 'x' },
  '[[',
  '<cmd>lua vim.opt_local.conceallevel = vim.opt_local.conceallevel > 0 and 0 or 2<CR>',
  {
    desc = 'Toggle markdown list markers',
  }
)
vim.keymap.set(
  { 'n', 'x' },
  ']]',
  '<cmd>lua vim.opt_local.conceallevel = vim.opt_local.conceallevel > 0 and 0 or 2<CR>',
  {
    desc = 'Toggle markdown list markers',
  }
)

-- Toggle a paragraph between prose and a comment block.
vim.keymap.set('n', 'Q', function()
  local conceal = vim.wo.conceallevel
  vim.wo.conceallevel = conceal == 2 and 0 or 2
end, { desc = 'Toggle markdown paragraph comments' })
