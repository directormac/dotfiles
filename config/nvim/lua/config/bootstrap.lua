-- Nix info plumbing + lz.n bootstrap.
-- Runs before anything else in init.lua: every other file reads `nixInfo`.

-- Prevent plugins (like which-key) from mistaking external lazy.nvim on packpath for an active lazy manager
package.loaded['lazy'] = false
package.preload['lazy'] = function() return false end

-- Set up a global in a way that also handles non-nix compat
if vim.g.nix_info_plugin_name then
  local ok, info = pcall(require, vim.g.nix_info_plugin_name)
  _G.nixInfo = ok and info or setmetatable({}, {
    __call = function(_, default) return default end,
  })
else
  _G.nixInfo = setmetatable({}, {
    __call = function(_, default) return default end,
  })
end
nixInfo.isNix = vim.g.nix_info_plugin_name ~= nil

function nixInfo.get_nix_plugin_path(name)
  return nixInfo(nil, 'plugins', 'lazy', name) or nixInfo(nil, 'plugins', 'start', name)
end

-- Initialize lz.n
local lzn = require('lz.n')
_G.lzn = lzn
nixInfo.lzn = lzn

-- Global config utilities and icons
_G.Util = require('config.util')
_G.Icons = require('config.icons')

-- Hook lz.n keys handler to support dynamic function specs (e.g. keys = function() return { ... } end)
local keys_handler = require('lz.n.handler.keys')
local orig_keys_parse = keys_handler.parse
keys_handler.parse = function(plugin, keys_spec)
  if type(keys_spec) == 'function' then
    local ok, res = pcall(keys_spec, plugin)
    if ok and type(res) == 'table' then
      keys_spec = res
    elseif not ok then
      vim.notify(
        'Failed to evaluate keys function for ' .. tostring(plugin.name) .. ': ' .. tostring(res),
        vim.log.levels.ERROR
      )
    end
  end
  return orig_keys_parse(plugin, keys_spec)
end

-- Auto-filter plugins not provisioned by Nix
local spec_mod = require('lz.n.spec')
local orig_parse = spec_mod.parse
spec_mod.parse = function(spec)
  local result = orig_parse(spec)
  if vim.g.nix_info_plugin_name then
    for name, plugin in pairs(result) do
      if plugin.auto_enable ~= false and not nixInfo.get_nix_plugin_path(name) then result[name] = nil end
    end
  end
  return result
end

-- Enable module-based on-demand loading
require('config.auto_require').enable()
