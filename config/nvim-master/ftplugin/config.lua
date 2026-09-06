-- Titlestring (Ghostty)
-- if vim.fn.getenv('TERMINAL') == 'ghostty' then

local filepath = vim.env.GHOSTTY_RESOURCES_DIR .. '/../vim/' .. 'ftplugin' .. '/ghostty.vim'

print(filepath)

vim.opt.title = true
vim.opt.titlestring = "%{fnamemodify(getcwd(), ':t')}"

local ghostty_resources_dir = vim.env.GHOSTTY_RESOURCES_DIR or ' '

if not ghostty_resources_dir then
  vim.notify('Failed to locate ghostty roeources. . ')
  return
end

local dirs = { 'ftplugin', 'ftdetect', 'syntax' }

for index, value in ipairs(dirs) do
  local filepath = ghostty_resources_dir() .. '/../vim/' .. value .. '/ghostty.vim'
  vim.notify(filepath)
  vim.notify(index .. value)
end

-- require( .. '../vim/')
-- end
