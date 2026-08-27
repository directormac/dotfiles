return {
    {
        "hiphish/rainbow-delimiters.nvim",
        event = { "VeryLazy" },
        config = function()
            require("rainbow-delimiters.setup").setup {
                highlight = {
                    "RainbowDelimiterOrange",
                    "RainbowDelimiterYellow",
                    "RainbowDelimiterGreen",
                    "RainbowDelimiterCyan",
                    "RainbowDelimiterBlue",
                    "RainbowDelimiterViolet",
                    "RainbowDelimiterRed",
                },
            }
        end,
    },

}
