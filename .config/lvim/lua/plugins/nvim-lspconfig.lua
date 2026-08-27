local function on_attach(client, bufnr)
    -- LSP key bindings
    local keybinds = require "config.keybinds"
    for _, km in ipairs(keybinds.lsp) do
        vim.keymap.set(
            km.mode,
            km.keymap,
            km.action,
            { buffer = bufnr, noremap = true, silent = true, desc = "[LSP]: " .. km.desc }
        )
    end

    -- Format on save
    if client.name == "ts_ls" then
        vim.api.nvim_create_autocmd("BufWritePost", {
            buffer = bufnr,
            callback = function()
                local filepath = vim.fn.expand("%:p")
                vim.fn.jobstart({ "prettier", "--write", filepath }, {
                    on_exit = function()
                        -- Reload the buffer to show formatting changes
                        vim.cmd("checktime")
                    end
                })
            end
        })
    else
        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
                vim.lsp.buf.format()
            end,
        })
    end
end

local servers_dir = "lsp"
local servers = { "rust_analyzer", "lua_ls", "ts_ls" }
local icons = require "config.icons"
return {
    {
        "neovim/nvim-lspconfig",
        event = { "VeryLazy" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            { "mason-org/mason.nvim",           event = "VeryLazy" },
            { "mason-org/mason-lspconfig.nvim", event = "VeryLazy" },
        },
        config = function()
            local cmp_nvim_lsp = require "cmp_nvim_lsp"
            local mason = require "mason"
            local mason_lsp = require "mason-lspconfig"

            local capabilities = vim.lsp.protocol.make_client_capabilities()
            capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

            if not mason.has_setup then
                mason.setup {}
            end
            mason_lsp.setup {}

            for _, server in ipairs(servers) do
                local server_dir = servers_dir .. "." .. server
                local conf_ok, conf = pcall(require, server_dir)
                vim.lsp.config(server, {
                    capabilities = capabilities,
                    on_attach = on_attach,
                    settings = conf_ok and conf.settings or nil,
                    filetypes = conf_ok and conf.filetypes or nil
                })
            end

            vim.diagnostic.config {
                -- disable virtual text
                virtual_text = true,

                -- show signs
                signs = {
                    text = {
                        [vim.diagnostic.severity.ERROR] = icons.error,
                        [vim.diagnostic.severity.WARN] = icons.warn,
                        [vim.diagnostic.severity.HINT] = icons.hint,
                        [vim.diagnostic.severity.INFO] = icons.info,
                    },
                },

                update_in_insert = true,
                underline = true,
                severity_sort = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    source = "always",
                    header = "",
                    prefix = "",
                },
            }
        end
    },
}
