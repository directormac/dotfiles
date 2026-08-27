return {
    {
        "shellRaining/hlchunk.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("hlchunk").setup {
                indent = {
                    enable = true,
                    style = {
                        { link = "Base01Fg" },
                    },
                },
            }
        end,
    },
    {
        "nmac427/guess-indent.nvim",
        event = { "BufWritePre", "BufReadPre", "BufNewFile" },
        config = function()
            require("guess-indent").setup {
                auto_cmd = true,
            }
        end,
    },
}
