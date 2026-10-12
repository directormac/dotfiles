local M = {}

local builtin_require = nil
local loading = {}

---Find which lazy plugin provides a given lua module
---@param mod string
---@return string? plugin_name
local function find_plugin_for_mod(mod)
  local path_mod = mod:gsub('%.', '/')
  local top_mod = mod:match('^([^.]+)%..*') or mod

  local candidates = {
    'lua/' .. path_mod .. '.lua',
    'lua/' .. path_mod .. '/init.lua',
    'lua/' .. top_mod .. '.lua',
    'lua/' .. top_mod .. '/init.lua',
  }

  -- 1. Fast Nix-store lookup via nixInfo
  if _G.nixInfo and nixInfo.plugins and nixInfo.plugins.lazy then
    for name, path in pairs(nixInfo.plugins.lazy) do
      for _, rel in ipairs(candidates) do
        if vim.uv.fs_stat(path .. '/' .. rel) then return name end
      end
    end
  end

  -- 2. Fallback packpath scan (for non-nix or extra packpaths)
  for _, packpath in ipairs(vim.opt.packpath:get()) do
    for _, opt_path in ipairs(vim.fn.expand(packpath .. '/pack/*/opt/*', false, true)) do
      for _, rel in ipairs(candidates) do
        if vim.uv.fs_stat(opt_path .. '/' .. rel) then return vim.fs.basename(opt_path) end
      end
    end
  end

  return nil
end

---@param mod string
---@return any
local function require_hook(mod)
  -- 1. Try default require
  local ok, val = pcall(builtin_require, mod)
  if ok then return val end

  -- 2. Prevent recursion if the module is already being triggered
  if loading[mod] then error(val) end

  -- 3. Check if an unloaded plugin provides this module
  local plugin_name = find_plugin_for_mod(mod)
  if plugin_name and _G.lzn then
    loading[mod] = true
    local load_ok, load_err = pcall(_G.lzn.trigger_load, plugin_name)
    loading[mod] = nil

    if load_ok then
      return builtin_require(mod)
    else
      vim.notify(
        'Failed to lazy load ' .. plugin_name .. ' for module ' .. mod .. ': ' .. tostring(load_err),
        vim.log.levels.ERROR
      )
    end
  end

  error(val)
end

function M.enable()
  if builtin_require ~= nil then return end
  builtin_require = _G.require
  _G.require = require_hook
end

function M.disable()
  if builtin_require == nil then return end
  _G.require = builtin_require
  builtin_require = nil
end

return M
