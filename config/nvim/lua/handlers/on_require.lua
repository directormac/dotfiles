---@type lze.Handler
---Standalone `on_require` handler for `lze`.
---Uses Lua's standard `package.loaders` (or `package.searchers`) to intercept `require()`
---calls matching specified module prefixes and lazy-load the corresponding plugin(s).
local M = {
  spec_field = 'on_require',
  set_lazy = true,
}

---@type table<string, string[]>
local states = {}

local new_loader = function(mod_path)
  local plugins = {}
  for name, mod_paths in pairs(states) do
    for _, v in ipairs(mod_paths) do
      if mod_path and mod_path:sub(1, #v) == v then
        table.insert(plugins, name)
        break
      end
    end
  end

  if next(plugins) ~= nil then
    return function()
      package.loaded[mod_path] = nil
      require('lze').trigger_load(plugins)
      return require(mod_path)
    end
  end

  return "\n\tlze.on_require: no plugin registered to load on require of '" .. tostring(mod_path) .. "'"
end

---Called before plugin `name` loads: clear any pending on_require state for it
---@param name string
function M.before(name)
  states[name] = nil
end

---Initialize handler by registering the loader in package.loaders / package.searchers
function M.init()
  local loaders = package.loaders or package.searchers
  for _, v in ipairs(loaders) do
    if v == new_loader then return end
  end
  table.insert(loaders, new_loader)
end

---Cleanup loader from package.loaders and clear states
function M.cleanup()
  local loaders = package.loaders or package.searchers
  for i, v in ipairs(loaders) do
    if v == new_loader then
      table.remove(loaders, i)
      break
    end
  end
  states = {}
end

---Adds a plugin to be lazy loaded upon requiring any submodule of provided mod paths
---@param plugin lze.Plugin
function M.add(plugin)
  local on_req = plugin.on_require
  if not on_req then return end

  ---@type string[]
  local mod_paths = {}
  if type(on_req) == 'table' then
    mod_paths = on_req
  elseif type(on_req) == 'string' then
    mod_paths = { on_req }
  else
    return
  end

  local pname = plugin.name or plugin[1]
  if not pname then return end

  states[pname] = mod_paths
end

return M
