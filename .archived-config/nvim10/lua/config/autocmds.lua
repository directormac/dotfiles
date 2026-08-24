-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.filetype.add({
  extension = {
    mdx = "markdown.mdx",
    postcss = "css",
    pcss = "css",
  },
})

vim.treesitter.language.register("markdown.mdx", "mdx")
vim.treesitter.language.register("css", "postcss")
vim.treesitter.language.register("css", "pcss")
