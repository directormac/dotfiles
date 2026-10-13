return {
  'snacks.nvim',
  lazy = false,
  priority = 1000,
  keys = {
    { '<leader>ps', function() Snacks.profiler.scratch() end, desc = 'Profiler Scratch Bufer' },
  },
  ---@type snacks.Config
  opts = {
    ---@class snacks.profiler.Config
    profiler = {
      enabled = true,
    },
  },
  after = function()
    -- Setup globals for debugging
    _G.dd = function(...) Snacks.debug.inspect(...) end
    _G.bt = function() Snacks.debug.backtrace() end
  end,
}
