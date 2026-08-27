return {
    {
        "llGaetanll/base16.nvim",
        priority = 1000,
        opts = {
            default_theme = "default-dark",
            on_change = require "highlights"
        },
    },
}
