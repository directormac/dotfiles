-- Titlestring (Ghostty)
if vim.fn.getenv('TERM_PROGRAM') == 'ghostty' then
  vim.opt.title = true
  vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')}"
  require(vim.env.GHOSTTY_RESOURCES_DIR .. '/../vim/vimfiles')
end
