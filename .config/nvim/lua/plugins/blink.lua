return {
  {
    "saghen/blink.cmp",
    opts = function(_, opts)
      return vim.tbl_deep_extend("force", opts, {})
    end,
  },
}
