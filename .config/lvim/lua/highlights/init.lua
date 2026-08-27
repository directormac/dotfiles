local util = require "highlights.util"

local gen_colors = function(theme)
    return {
        -- darks
        bg0    = theme.base00,
        bg1    = theme.base01,
        bg2    = theme.base02,
        bg3    = theme.base03,

        -- lights
        fg0    = theme.base04,
        fg1    = theme.base05,
        fg2    = theme.base06,
        fg3    = theme.base07,

        -- accent colors
        red    = theme.base08,
        orange = theme.base09,
        yellow = theme.base0A,
        green  = theme.base0B,
        cyan   = theme.base0C,
        blue   = theme.base0D,
        purple = theme.base0E,
        gray   = theme.base0F,
    }
end

return function(theme)
    local colors = gen_colors(theme)

    local fixes = { "cmp", "snacks", "misc", "telescope" }
    local groups = util.merge_groups(fixes, colors)

    util.set_highlights(groups)
end
