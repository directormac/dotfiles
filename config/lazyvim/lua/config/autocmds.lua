-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.filetype.add({
  extension = {
    zsh = 'zsh',
    tmux = 'tmux',
    mjml = 'html',
    ['mjml.eex'] = 'html.eex',
    mdx = 'markdown.mdx',
    postcss = 'css',
    pcss = 'css',
    caddy = 'caddy',
  },
  filename = {
    ['Caddyfile'] = 'caddy',
    ['docker-compose.yaml'] = 'yaml.docker-compose',
    ['.zshrc'] = 'zsh',
    ['.zshenv'] = 'zsh',
  },
  pattern = {
    -- Matches Caddyfile.dev, Caddyfile.local, etc.
    ['Caddyfile%.%w+'] = 'caddy',

    -- Matches compose.dev.yaml, compose.infra.yaml, etc.
    ['compose%.%w+%.yaml'] = 'yaml.docker-compose',

    -- If you want to catch Dockerfile.dev as well:
    ['Dockerfile%.%w+'] = 'dockerfile',
  },
})

vim.treesitter.language.register('markdown.mdx', 'mdx')
vim.treesitter.language.register('css', 'postcss')
vim.treesitter.language.register('css', 'pcss')


-- Don't auto-wrap comments and don't insert comment leader after hitting 'o'.
-- Do on `FileType` to always override these changes from filetype plugins.

-- stylua: ignore
vim.api.nvim_create_autocmd(
  'FileType',
  { callback =
  function()
    vim.cmd('setlocal formatoptions-=c formatoptions-=o')
  end,
  desc = 'Proper formatoptions' }
)

-- Reload files changed outside of Neovim
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  desc = 'Reload files changed outside of Neovim',
  group = vim.api.nvim_create_augroup('checktime_extended', { clear = true }),
  callback = function()
    if vim.o.buftype ~= 'nofile' then vim.cmd('checktime') end
  end,
})
