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

-- Preview current markdown buffer with mdcat in a window below (like a help window)
local function preview_markdown_mdcat()
  local file = vim.api.nvim_buf_get_name(0)
  local tmpfile = nil
  if file == '' or vim.bo.modified then
    tmpfile = vim.fn.tempname() .. '.md'
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    vim.fn.writefile(lines, tmpfile)
    file = tmpfile
  end

  local height = math.max(12, math.floor(vim.o.lines * 0.35))
  vim.cmd('botright ' .. height .. 'split')
  local win = vim.api.nvim_get_current_win()
  local term_cmd = string.format('mdcat -p %s', vim.fn.shellescape(file))
  if tmpfile then
    term_cmd = string.format('mdcat -p %s; rm -f %s', vim.fn.shellescape(file), vim.fn.shellescape(tmpfile))
  end

  vim.fn.termopen(term_cmd, {
    on_exit = function()
      if vim.api.nvim_win_is_valid(win) then vim.api.nvim_win_close(win, true) end
    end,
  })
  vim.cmd('startinsert')
end

vim.api.nvim_buf_create_user_command(0, 'MdcatPreview', preview_markdown_mdcat, {
  desc = 'Preview current markdown buffer with mdcat in a window below',
})

vim.keymap.set('n', '<leader>mp', preview_markdown_mdcat, {
  buffer = true,
  desc = 'Preview markdown with mdcat (bottom window)',
})
vim.keymap.set('n', '<leader>cp', preview_markdown_mdcat, {
  buffer = true,
  desc = 'Preview markdown with mdcat (bottom window)',
})
