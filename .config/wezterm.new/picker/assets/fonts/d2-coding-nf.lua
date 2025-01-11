---@module "picker.assets.fonts.d2-coding-nf"

---@class PickList
local M = {}

local wt = require "wezterm"

M.get = function()
  return { id = "d2-coding-nf", label = "D2 Coding Ligature Nerd Font" }
end

M.activate = function(Config, _)
  local monaspace_features =
    { "dlig", "ss01", "ss02", "ss03", "ss04", "ss05", "ss06", "ss07", "ss08" }

  Config.font = wt.font_with_fallback {
    {
      family = "D2CodingLigature Nerd Font",
      weight = "Regular",
      harfbuzz_features = {
        "cv06",
        "cv12",
        "cv14",
        "cv16",
        "cv25",
        "cv26",
        "cv28",
        "cv29",
        "cv31",
        "cv32",
        "ss03",
        "ss04",
        "ss05",
        "ss07",
        "ss09",
      },
    },
    { family = "Noto Color Emoji" },
    { family = "LegacyComputing" },
  }

  Config.cell_width = 1.0
  Config.font_rules = {
    {
      intensity = "Normal",
      italic = true,
      font = wt.font_with_fallback {
        {
          family = "Monaspace Radon",
          style = "Normal",
          weight = "Regular",
          stretch = "Expanded",
          harfbuzz_features = monaspace_features,
        },
        { family = "Symbols Nerd Font" },
      },
    },
    {
      intensity = "Bold",
      italic = true,
      font = wt.font_with_fallback {
        {
          family = "Monaspace Krypton Var",
          style = "Italic",
          weight = "Black",
          harfbuzz_features = monaspace_features,
          scale = 1.1,
        },
        { family = "Symbols Nerd Font" },
      },
    },
  }
end

return M
