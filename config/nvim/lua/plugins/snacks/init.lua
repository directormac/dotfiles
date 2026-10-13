return {
  'snacks.nvim',
  auto_enable = true,
  lazy = false,
  priority = 1000,
  opts = {},
  after = function()
    -- Setup globals for debugging
    _G.dd = function(...) Snacks.debug.inspect(...) end
    _G.bt = function() Snacks.debug.backtrace() end
  end,
}
