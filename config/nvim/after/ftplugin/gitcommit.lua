-- Git commit message filetype settings. Sourced automatically on FileType=gitcommit.

-- Commit message lines should be wrapped by the editor, not hard wrapped at 72.
vim.opt_local.wrap = true
vim.opt_local.linebreak = true
vim.opt_local.breakindent = true

-- Spell check the message, but ignore long identifiers and urls.
vim.opt_local.spell = true
vim.opt_local.spelllang = 'en'

-- Count the subject line characters, they are limited to 50 by convention.
vim.api.nvim_create_autocmd({ 'TextChangedI', 'InsertLeave' }, {
  buffer = 0,
  callback = function()
    local line = vim.api.nvim_get_current_line()
    vim.notify(string.format('subject line: %d characters', #line), vim.log.levels.DEBUG)
  end,
})
