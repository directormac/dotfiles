---@module "picker.font-size"

local Picker = require("utils").class.picker

return Picker.new {
  title = "󰢷  Font size",
  subdir = "font-sizes",
  fuzzy = true,
  comp = function(a, b)
    local label = "Reset"
    return (a.label == label) or (b.label ~= label and a.label < b.label)
  end,
}
