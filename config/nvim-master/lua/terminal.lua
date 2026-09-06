do
  if os.getenv('TMUX') then vim.opt.title = true end

  print(os.getenv('TERM'))
end

print(vim.fs.normalize(vim.env.GHOSTTY_RESOURCES_DIR .. '/../vim/vimfiles' .. '/ftplugin' .. '/ghostty.vim'))

local filepath = vim.env.GHOSTTY_RESOURCES_DIR .. '/../vim/vimfiles/' .. 'ftplugin' .. '/ghostty.vim'

print(filepath)

vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')}"

local ghostty_resources_dir = vim.env.GHOSTTY_RESOURCES_DIR or ''

if not ghostty_resources_dir then
  vim.notify('Failed to locate ghostty roeources. . ')
  return
end

local dirs = { 'ftplugin', 'ftdetect', 'syntax' }

for index, value in ipairs(dirs) do
  local filepath = ghostty_resources_dir .. '/../vim/' .. value .. '/ghostty.vim'
  vim.notify(filepath)
  vim.notify(index .. value)
end
