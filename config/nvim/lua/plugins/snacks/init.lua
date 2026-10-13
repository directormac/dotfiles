local Util = require('config.util')

local modules = {}
local extra_specs = {}
local loaded = {}

local function process_file(modname)
  if loaded[modname] or modname == 'init' then return end
  loaded[modname] = true

  local ok, mod = pcall(require, 'plugins.snacks.' .. modname)
  if not ok or type(mod) ~= 'table' then return end

  -- 1. Spec lists (e.g. auxiliary.lua returning { { 'nvim-float', ... }, ... })
  if vim.islist(mod) and type(mod[1]) == 'table' then
    for _, spec in ipairs(mod) do
      table.insert(extra_specs, spec)
    end
    return
  end

  -- 2. Full plugin specs (e.g. { 'snacks.nvim', keys = ..., opts = ... })
  if mod[1] == 'snacks.nvim' or mod.name == 'snacks.nvim' then
    table.insert(extra_specs, mod)
    return
  end

  -- 3. Declarative fragment tables with keys table: convert to snacks spec
  if mod.keys and type(mod.keys) == 'table' then
    table.insert(extra_specs, {
      'snacks.nvim',
      keys = mod.keys,
      opts = mod.opts or {},
    })
    return
  end

  -- 4. Submodule table (opts, setup, imperative keys function)
  table.insert(modules, mod)
end

-- Recursively scan all files in lua/plugins/snacks/**
local function scan_dir(dir, rel_path)
  local handle = vim.uv.fs_scandir(dir)
  if not handle then return end
  while true do
    local name, ty = vim.uv.fs_scandir_next(handle)
    if not name then break end
    local full_path = vim.fs.joinpath(dir, name)
    ty = ty or (vim.uv.fs_stat(full_path) or {}).type

    if (ty == 'file' or ty == 'link') and name:sub(-4) == '.lua' then
      local subname = name:sub(1, -5)
      local modname = rel_path ~= '' and (rel_path .. '.' .. subname) or subname
      process_file(modname)
    elseif ty == 'directory' then
      local subrel = rel_path ~= '' and (rel_path .. '.' .. name) or name
      scan_dir(full_path, subrel)
    end
  end
end

local dirs = vim.api.nvim_get_runtime_file('lua/plugins/snacks', true)
for _, dir in ipairs(dirs) do
  scan_dir(dir, '')
end

-- Aggregate all opts from submodules (e.g. toggle.lua)
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
      if type(mod.keys) == 'function' then mod.keys() end
    end

    -- Setup globals for debugging
    _G.dd = function(...) Snacks.debug.inspect(...) end
    _G.bt = function() Snacks.debug.backtrace() end
  end,
}

local specs = { snacks_spec }
for _, spec in ipairs(extra_specs) do
  table.insert(specs, spec)
end

return specs
