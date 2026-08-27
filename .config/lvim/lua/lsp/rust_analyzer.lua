return {
    settings = {
        ["rust-analyzer"] = {
            check = {
                command = "clippy",
            },
            diagnostics = {
                enable = true,
            },
            imports = {
                granularity = { group = "item" },
            },
            rustfmt = {
                overrideCommand = { "rustfmt", "+nightly", "--edition", "2024" },
            },
            inlayHints = {
                parameterHints = true,
                bindingModeHints = {
                    enable = true,
                },
                closureReturnTypeHints = {
                    enable = true,
                },
                lifetimeElisionHints = {
                    enable = true,
                },
            },
        },
    },
}
