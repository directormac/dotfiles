-- Spec preprocessing for lz.n:
-- 1. Normalizes plugin names (e.g. "folke/flash.nvim" -> "flash.nvim").
-- 2. Flattens nested `specs = { ... }` child specs (LazyVim / lazy.nvim style).
-- 3. Deep-merges multiple specs for the same plugin (opts, keys, after/before, load_before).
-- 4. Filters optional plugins and auto-filters plugins not provisioned by Nix.
-- 5. Recursively discovers specs in directories with package boundary support (init.lua).
-- 6. Defers opts evaluation (supporting functions) and auto-defaults `.setup(opts)`.

local M = {}

---@type table<string, boolean>
local is_explicit = {}

--- Strips owner prefix from repository name if present.
---@param name string|unknown
---@return string|unknown
function M.normalize_name(name)
  if type(name) ~= 'string' then return name end
  return name:match('^[^/]+/(.+)$') or name
end

--- Resolves the options for a plugin (convenience alias).
---@param plugin lz.n.Plugin|table
---@return table
function M.opts(plugin) return M.resolve_opts(plugin) end

--- Evaluates all registered opts builders (tables and functions) into a final opts table.
---@param plugin lz.n.Plugin|table
---@return table
function M.resolve_opts(plugin)
  if plugin._opts_resolved then return plugin.opts or {} end
  plugin._opts_resolved = true

  local base = {}
  local builders = plugin._opts_builders or {}
  if #builders == 0 and plugin.opts ~= nil then table.insert(builders, plugin.opts) end

  local Util = require('config.util')
  for _, b in ipairs(builders) do
    if type(b) == 'function' then
      local ok, res = pcall(b, plugin, base)
      if ok then
        if type(res) == 'table' then base = Util.merge(base, res) end
        -- If res == nil, the function mutated base in-place; base already has the changes
      elseif not ok then
        vim.schedule(
          function()
            vim.notify(
              'Failed to evaluate opts function for ' .. tostring(plugin.name) .. ': ' .. tostring(res),
              vim.log.levels.ERROR
            )
          end
        )
      end
    elseif type(b) == 'table' then
      base = Util.merge(base, vim.deepcopy(b))
    end
  end

  plugin.opts = base
  return base
end

--- Merges incoming spec into existing plugin table.
---@param target lz.n.Plugin
---@param spec lz.n.PluginSpec
function M.merge_into_plugin(target, spec)
  -- 1. Track opts builders
  if spec.opts ~= nil then
    target._opts_builders = target._opts_builders or {}
    if #target._opts_builders == 0 and target.opts ~= nil then table.insert(target._opts_builders, target.opts) end
    table.insert(target._opts_builders, spec.opts)
    target.opts = spec.opts -- sentinel to indicate opts exist
  end

  -- 2. Merge keys (accumulate rather than overwrite)
  if spec.keys then
    local prev_keys = target.keys or {}
    local keys_h = require('lz.n.handler.keys')
    local dummy = { name = target.name }
    local k_spec = spec.keys
    if type(k_spec) == 'function' then
      local ok, res = pcall(k_spec, target, prev_keys)
      if ok and type(res) == 'table' then
        k_spec = res
      elseif not ok then
        vim.schedule(
          function()
            vim.notify(
              'Failed to evaluate keys function for ' .. tostring(target.name) .. ': ' .. tostring(res),
              vim.log.levels.ERROR
            )
          end
        )
      end
    end
    keys_h.parse(dummy, k_spec)
    if dummy.keys then
      for _, k in ipairs(dummy.keys) do
        table.insert(prev_keys, k)
      end
    end
    target.keys = prev_keys
  end

  -- 3. Chain after hooks
  if spec.after then
    local prev_after = target.after
    local new_after = spec.after
    if prev_after then
      target.after = function(plugin)
        prev_after(plugin)
        new_after(plugin)
      end
    else
      target.after = new_after
    end
  end

  -- 4. Chain before hooks
  if spec.before then
    local prev_before = target.before
    local new_before = spec.before
    if prev_before then
      target.before = function(plugin)
        prev_before(plugin)
        new_before(plugin)
      end
    else
      target.before = new_before
    end
  end

  -- 5. Merge dep_of / load_before
  if spec.load_before or spec.dep_of then
    local dep = spec.load_before or spec.dep_of
    local dep_list = type(dep) == 'table' and dep or { dep }
    local tdep = target.load_before or target.dep_of or {}
    local tdep_list = type(tdep) == 'table' and tdep or { tdep }
    for _, d in ipairs(dep_list) do
      if not vim.list_contains(tdep_list, d) then table.insert(tdep_list, d) end
    end
    target.load_before = tdep_list
  end

  -- 6. Other attributes: if target has nil, copy from spec, or allow non-optional spec to set flags
  for k, v in pairs(spec) do
    if
      k ~= 1
      and k ~= 'name'
      and k ~= 'opts'
      and k ~= 'keys'
      and k ~= 'after'
      and k ~= 'before'
      and k ~= 'specs'
      and k ~= 'load_before'
      and k ~= 'dep_of'
      and k ~= 'optional'
    then
      if target[k] == nil or (spec.priority ~= nil or spec.lazy == false) then target[k] = v end
    end
  end
end

--- Resolves candidate module name and calls .setup(opts).
---@param raw_name string
---@param main? string
---@param opts table
function M.auto_setup(raw_name, main, opts)
  local name = raw_name:match('^[^/]+/(.+)$') or raw_name
  local clean = name:gsub('[-.]nvim$', ''):gsub('[-.]lua$', '')
  local no_digits = clean:gsub('%d+$', '')
  local no_prefix = clean:gsub('^nvim[-_.]', '')
  local no_prefix_digits = no_digits:gsub('^nvim[-_.]', '')

  local candidates = {}
  local seen = {}
  local function add(c)
    if c and c ~= '' and not seen[c] then
      seen[c] = true
      table.insert(candidates, c)
    end
  end

  add(main)
  add(clean)
  add(no_digits)
  add(no_prefix)
  add(no_prefix_digits)
  add(clean:gsub('%-', '_'))
  add(clean:gsub('%-', '.'))
  add(name)
  add(raw_name)

  local target_mod
  for _, cand in ipairs(candidates) do
    local ok, m = pcall(require, cand)
    if ok and type(m) == 'table' and type(m.setup) == 'function' then
      target_mod = m
      break
    end
  end

  if target_mod then
    target_mod.setup(opts or {})
  else
    vim.schedule(function() vim.notify('Failed to auto-setup module for plugin: ' .. raw_name, vim.log.levels.WARN) end)
  end
end

--- Imports a Lua module and normalizes its spec return value.
---@param modname string
---@param result table<string, lz.n.Plugin>
---@param spec_mod table
local function import_modname(modname, result, spec_mod)
  local ok, mod = pcall(require, modname)
  if not ok then
    vim.schedule(function()
      local err = type(mod) == 'string' and (': ' .. mod) or ''
      vim.notify("Failed to load module '" .. modname .. "'" .. err, vim.log.levels.ERROR)
    end)
    return
  end
  if type(mod) ~= 'table' then
    vim.schedule(
      function()
        vim.notify("Invalid plugin spec module '" .. modname .. "' of type '" .. type(mod) .. "'", vim.log.levels.ERROR)
      end
    )
    return
  end
  spec_mod._normalize(mod, result)
end

--- Recursively crawls directory to discover plugin specs.
--- Imports init.lua as the directory package (if present) and all sibling/submodule spec files.
---@param dir_path string
---@param mod_prefix string
---@param result table<string, lz.n.Plugin>
---@param spec_mod table
---@param imported table<string, boolean>
local function crawl_dir(dir_path, mod_prefix, result, spec_mod, imported)
  local handle = vim.uv.fs_scandir(dir_path)
  if not handle then return end

  local subdirs = {}

  while true do
    local name, ty = vim.uv.fs_scandir_next(handle)
    if not name then break end
    local full_path = vim.fs.joinpath(dir_path, name)
    ty = ty or (vim.uv.fs_stat(full_path) and vim.uv.fs_stat(full_path).type)

    if (ty == 'file' or ty == 'link') and name:sub(-4) == '.lua' then
      local full_mod = (name == 'init.lua') and mod_prefix or (mod_prefix .. '.' .. name:sub(1, -5))
      if not imported[full_mod] then
        imported[full_mod] = true
        import_modname(full_mod, result, spec_mod)
      end
    elseif ty == 'directory' then
      table.insert(subdirs, { path = full_path, name = name })
    end
  end

  for _, sub in ipairs(subdirs) do
    crawl_dir(sub.path, mod_prefix .. '.' .. sub.name, result, spec_mod, imported)
  end
end

--- Handles `{ import = ... }` specs recursively.
---@param spec lz.n.SpecImport
---@param result table<string, lz.n.Plugin>
---@param spec_mod table
function M.import_spec(spec, result, spec_mod)
  if spec.import == 'lz.n' then
    vim.schedule(function() vim.notify("Plugins modules cannot be called 'lz.n'", vim.log.levels.ERROR) end)
    return
  end
  if type(spec.import) ~= 'string' then
    vim.schedule(
      function()
        vim.notify(
          "Invalid import spec. The 'import' field should be a module name: " .. vim.inspect(spec),
          vim.log.levels.ERROR
        )
      end
    )
    return
  end
  if spec.enabled == false or (type(spec.enabled) == 'function' and not spec.enabled()) then return end

  local modpath = vim.fs.joinpath(unpack(vim.split(spec.import, '.', { plain = true })))
  local import_root = vim.api.nvim_get_runtime_file(vim.fs.joinpath('lua', modpath .. '.lua'), true)
  if #import_root == 1 then import_modname(spec.import, result, spec_mod) end

  local import_dirs = vim.api.nvim_get_runtime_file(vim.fs.joinpath('lua', modpath), true)
  if #import_dirs > 0 then
    local imported = {}
    for _, dir in ipairs(import_dirs) do
      crawl_dir(dir, spec.import, result, spec_mod, imported)
    end
  end
end

--- Hook lz.n.spec to preprocess and merge specs.
function M.setup()
  -- Hook lz.n keys handler to support dynamic function specs (e.g. keys = function(plugin, keys) return { ... } end)
  local keys_handler = require('lz.n.handler.keys')
  local orig_keys_parse = keys_handler.parse
  keys_handler.parse = function(plugin, keys_spec)
    if type(keys_spec) == 'function' then
      local ok, res = pcall(keys_spec, plugin, plugin and plugin.keys)
      if ok and type(res) == 'table' then
        keys_spec = res
      elseif not ok then
        vim.schedule(
          function()
            vim.notify(
              'Failed to evaluate keys function for ' .. tostring(plugin and plugin.name) .. ': ' .. tostring(res),
              vim.log.levels.ERROR
            )
          end
        )
      end
    end
    return orig_keys_parse(plugin, keys_spec)
  end

  local spec_mod = require('lz.n.spec')
  local orig_normalize = spec_mod._normalize
  local orig_parse = spec_mod.parse

  spec_mod._normalize = function(spec, result)
    if type(spec) ~= 'table' then return end

    if spec_mod.is_spec_list(spec) then
      for _, sp in ipairs(spec) do
        spec_mod._normalize(sp, result)
      end
      return
    end

    if spec_mod.is_single_plugin_spec(spec) then
      local raw_name = spec[1] or spec.name
      local name = M.normalize_name(raw_name)
      spec[1] = name
      spec.name = name

      if not spec.optional then is_explicit[name] = true end

      local child_specs = spec.specs
      spec.specs = nil

      if result[name] then
        M.merge_into_plugin(result[name], spec)
      else
        orig_normalize(spec, result)
        if result[name] and spec.opts ~= nil then result[name]._opts_builders = { spec.opts } end
      end

      if child_specs and type(child_specs) == 'table' then
        for _, child in ipairs(child_specs) do
          spec_mod._normalize(child, result)
        end
      end
      return
    end

    if spec.import then
      M.import_spec(spec, result, spec_mod)
      return
    end

    orig_normalize(spec, result)
  end

  spec_mod.parse = function(spec)
    is_explicit = {}
    local result = orig_parse(spec)

    -- Filter out plugins marked optional that were never explicitly defined
    for name, plugin in pairs(result) do
      if plugin.optional == true and not is_explicit[name] then result[name] = nil end
    end

    -- Auto-filter plugins not provisioned by Nix
    if vim.g.nix_info_plugin_name and nixInfo and nixInfo.get_nix_plugin_path then
      for name, plugin in pairs(result) do
        if plugin.auto_enable ~= false and not nixInfo.get_nix_plugin_path(name) then result[name] = nil end
      end
    end

    -- Wrap after/before hooks to resolve opts on plugin load, and auto-default .setup(opts)
    for name, plugin in pairs(result) do
      if plugin.opts ~= nil or (plugin._opts_builders and #plugin._opts_builders > 0) then
        local orig_after = plugin.after
        plugin.after = function(p)
          local opts = M.resolve_opts(p)
          if plugin.config then
            if type(plugin.config) == 'function' then plugin.config(p, opts) end
          elseif plugin.auto_setup ~= false and plugin.config ~= false then
            M.auto_setup(p.name or name, p.main, opts)
          end
          if orig_after then orig_after(p) end
        end

        if plugin.before then
          local orig_before = plugin.before
          plugin.before = function(p)
            M.resolve_opts(p)
            orig_before(p)
          end
        end
      end
    end

    return result
  end
end

return M
