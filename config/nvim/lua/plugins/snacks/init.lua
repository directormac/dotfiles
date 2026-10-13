-- snacks.nvim modularized configuration
local modules = {
  require('plugins.snacks.ui'),
  require('plugins.snacks.indent'),
  require('plugins.snacks.lazygit'),
  require('plugins.snacks.dashboard'),
  require('plugins.snacks.explorer'),
  require('plugins.snacks.picker'),
  require('plugins.snacks.terminal'),
  require('plugins.snacks.notifier'),
  require('plugins.snacks.scratch'),
  require('plugins.snacks.words'),
  require('plugins.snacks.toggle'),
}

local Util = require('config.util')

-- Aggregate all opts from submodules
local merged_opts = {}
for _, mod in ipairs(modules) do
  if mod.opts then merged_opts = Util.merge(merged_opts, mod.opts) end
end

local snacks_spec = {
  'snacks.nvim',
  auto_enable = true,
  lazy = false,

  priority = 1000,
  after = function(plugin)
    local final_opts = Util.merge(merged_opts, plugin.opts or {})
    require('snacks').setup(final_opts)

    for _, mod in ipairs(modules) do
      if mod.setup then mod.setup() end
      if mod.keys then mod.keys() end
    end

    -- Setup some globals for debugging (lazy-loaded)
    _G.dd = function(...) Snacks.debug.inspect(...) end
    _G.bt = function() Snacks.debug.backtrace() end
  end,
}

local auxiliary_specs = require('plugins.snacks.auxiliary')

local specs = { snacks_spec }
for _, spec in ipairs(auxiliary_specs) do
  table.insert(specs, spec)
end

return specs
