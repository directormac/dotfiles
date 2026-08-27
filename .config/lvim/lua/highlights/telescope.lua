return function(colors)
    local search_color = { fg = colors.bg0, bg = colors.bg3 }
    local result_color = { bg = colors.bg2 }
    local preview_color = { bg = colors.bg1 }

    return {
        -- top left
        TelescopePromptTitle = { fg = colors.bg0, bg = colors.blue, bold = true },
        TelescopePromptBorder = { fg = search_color.bg, bg = search_color.bg },
        TelescopePromptNormal = { fg = search_color.fg, bg = search_color.bg },
        TelescopePromptPrefix = { fg = search_color.fg, bold = true },
        TelescopePromptCounter = { fg = colors.bg3 },

        -- bottom left
        TelescopeResultsTitle = { fg = colors.bg0, bg = colors.green, bold = true },
        TelescopeResultsBorder = { fg = result_color.bg, bg = result_color.bg },
        TelescopeResultsNormal = { fg = colors.fg0, bg = result_color.bg },
        TelescopeSelection = { bg = preview_color.bg },

        -- right
        TelescopePreviewTitle = { fg = colors.bg0, bg = colors.purple, bold = true },
        TelescopePreviewBorder = { fg = preview_color.bg, bg = preview_color.bg },
        TelescopePreviewNormal = { bg = preview_color.bg },
    }
end
