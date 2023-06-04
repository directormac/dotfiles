return {
  {
    "rcarriga/nvim-notify",
    opts = {
      timeout = 3500,
      background_colour = "#000000",
      level = vim.log.levels.WARN, -- help vim.log.levels
      render = "minimal",
      stages = "static",
    },
  },
}
