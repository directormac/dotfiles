---@module "picker.font"

local Picker = require("utils").class.picker

return Picker.new {
  title = "󰢷  Font picker",
  subdir = "fonts",
  fuzzy = true,
  comp = function(a, b)
    return (a.id == "reset") or (b.id ~= "reset" and a.label < b.label)
  end,
}
