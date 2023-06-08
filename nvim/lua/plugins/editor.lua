return {
  {
    "kevinhwang91/nvim-ufo", -- Better folds in Neovim
    dependencies = "kevinhwang91/promise-async",
    config = function()
      require("ufo").setup({
        provider_selector = function(bufnr, filetype, buftype)
          return { "treesitter", "indent" }
        end,
      })
    end,
  },
}
