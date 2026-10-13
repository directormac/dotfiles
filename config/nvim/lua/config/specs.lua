-- Spec preprocessing for lz.n:
-- 1. Normalizes plugin names (e.g. "folke/flash.nvim" -> "flash.nvim").
-- 2. Flattens nested `specs = { ... }` child specs (LazyVim / lazy.nvim style).
-- 3. Deep-merges multiple specs for the same plugin (opts, keys, after/before, load_before).
-- 4. Filters optional plugins and auto-filters plugins not provisioned by Nix.

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

--- Merges incoming spec into existing plugin table.
---@param target lz.n.Plugin
---@param spec lz.n.PluginSpec
function M.merge_into_plugin(target, spec)
  local Util = require('config.util')

  -- 1. Deep-merge opts
  if spec.opts then
    target.opts = Util.merge(target.opts or {}, vim.deepcopy(spec.opts))
  end

  -- 2. Merge keys
  if spec.keys then
    local keys_h = require('lz.n.handler.keys')
    keys_h.parse(target, spec.keys)
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
      if not vim.list_contains(tdep_list, d) then
        table.insert(tdep_list, d)
      end
    end
    target.load_before = tdep_list
  end

  -- 6. Other attributes: if target has nil, copy from spec, or allow non-optional spec to set flags
  for k, v in pairs(spec) do
    if k ~= 1 and k ~= 'name' and k ~= 'opts' and k ~= 'keys' and k ~= 'after' and k ~= 'before'
       and k ~= 'specs' and k ~= 'load_before' and k ~= 'dep_of' and k ~= 'optional' then
      if target[k] == nil or (spec.priority ~= nil or spec.lazy == false) then
        target[k] = v
      end
    end
  end
end

--- Hook lz.n.spec to preprocess and merge specs.
function M.setup()
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

      if not spec.optional then
        is_explicit[name] = true
      end

      local child_specs = spec.specs
      spec.specs = nil

      if result[name] then
        M.merge_into_plugin(result[name], spec)
      else
        orig_normalize(spec, result)
      end

      if child_specs and type(child_specs) == 'table' then
        for _, child in ipairs(child_specs) do
          spec_mod._normalize(child, result)
        end
      end
      return
    end

    orig_normalize(spec, result)
  end

  spec_mod.parse = function(spec)
    is_explicit = {}
    local result = orig_parse(spec)

    -- Filter out plugins marked optional that were never explicitly defined
    for name, plugin in pairs(result) do
      if plugin.optional == true and not is_explicit[name] then
        result[name] = nil
      end
    end

    -- Auto-filter plugins not provisioned by Nix
    if vim.g.nix_info_plugin_name and nixInfo and nixInfo.get_nix_plugin_path then
      for name, plugin in pairs(result) do
        if plugin.auto_enable ~= false and not nixInfo.get_nix_plugin_path(name) then
          result[name] = nil
        end
      end
    end

    return result
  end
end

return M
