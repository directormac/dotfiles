return {

  -- reference https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/editor.lua
  {
    "stevearc/conform.nvim",
    lazy = true,
    dependencies = { "mason.nvim" },
    cmd = "ConformInfo",
    keys = {
      {
        "<leader>cF",
        function()
          require("conform").format({ formatters = { "injected" }, timeout_ms = 3000 })
        end,
        mode = { "n", "x" },
        desc = "Format Injected Langs",
      },
    },
  },
}
