return {
  {
    "ghostty",
    dir = vim.env.GHOSTTY_RESOURCES_DIR .. "/../vim/vimfiles",
    lazy = false,
    cond = vim.env.GHOSTTY_RESOURCES_DIR ~= nil,
  },
}
