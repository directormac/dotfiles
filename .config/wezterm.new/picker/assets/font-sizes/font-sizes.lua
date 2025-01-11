---@module "picker.assets.font-sizes.font-sizes"

---@class PickList
local M = {}

M.get = function()
  local sizes = {}
  for i = 8, 30 do
    sizes[#sizes + 1] = { label = ("%2dpt"):format(i), id = tostring(i) }
  end
  sizes[#sizes + 1] = { id = tostring(require("config.font").font_size), label = "Reset" }

  return sizes
end

M.activate = function(Config, opts)
  Config.font_size = tonumber(opts.id)
end

return M
