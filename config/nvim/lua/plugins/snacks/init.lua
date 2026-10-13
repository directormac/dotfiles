-- snacks.nvim modularized configuration (flake-parts style auto-discovery)
local Util = require('config.util')

local modules = {}
local extra_specs = {}
local loaded = {}

-- Auto-discover all files in lua/plugins/snacks/ (except init.lua and auxiliary.lua)
local dirs = vim.api.nvim_get_runtime_file('lua/plugins/snacks', true)
for _, dir in ipairs(dirs) do
  local handle = vim.uv.fs_scandir(dir)
  while handle do
    local name, ty = vim.uv.fs_scandir_next(handle)
    if not name then break end
    if (ty == 'file' or ty == 'link') and name:sub(-4) == '.lua' then
      local modname = name:sub(1, -5)
      if modname ~= 'init' and modname ~= 'auxiliary' and not loaded[modname] then
        loaded[modname] = true
        local ok, mod = pcall(require, 'plugins.snacks.' .. modname)
        if ok and type(mod) == 'table' then
          if mod[1] == 'snacks.nvim' or mod.name == 'snacks.nvim' then
            table.insert(extra_specs, mod)
          else
            table.insert(modules, mod)
          end
        end
      end
    end
  end
end

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
for _, spec in ipairs(extra_specs) do
  table.insert(specs, spec)
end
for _, spec in ipairs(auxiliary_specs) do
  table.insert(specs, spec)
end

return specs
