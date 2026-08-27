return {
    {
        "sindrets/diffview.nvim", -- git diff integration
        event = { "VeryLazy" },
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts = {
            enhanced_diff_hl = true
        }
    },
}
