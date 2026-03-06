-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here
--
-- Show Diagnostic popup on cursor hover
-- local diag_float_grp = vim.api.nvim_create_augroup("DiagnosticFloat", { clear = true })
-- vim.api.nvim_create_autocmd("CursorHold", {
--   callback = function()
--     vim.diagnostic.open_float(nil, { focusable = false })
--   end,
--   group = diag_float_grp,
-- })

vim.filetype.add({
  extension = {
    mdx = "markdown.mdx",
    postcss = "css",
    pcss = "css",
    caddy = "caddy",
  },
  filename = {
    ["Caddyfile"] = "caddy",
    ["docker-compose.yaml"] = "yaml.docker-compose",
  },
  pattern = {
    -- Matches Caddyfile.dev, Caddyfile.local, etc.
    ["Caddyfile%.%w+"] = "caddy",

    -- Matches compose.dev.yaml, compose.infra.yaml, etc.
    ["compose%.%w+%.yaml"] = "yaml.docker-compose",

    -- If you want to catch Dockerfile.dev as well:
    ["Dockerfile%.%w+"] = "dockerfile",
  },
})

vim.treesitter.language.register("markdown.mdx", "mdx")
vim.treesitter.language.register("css", "postcss")
vim.treesitter.language.register("css", "pcss")
