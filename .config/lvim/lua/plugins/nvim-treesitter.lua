-- See: https://github.com/nvim-treesitter/nvim-treesitter (main branch)
--
-- The main branch builds parsers from source and needs the `tree-sitter` CLI
-- on PATH. We install it through mason (into nvim's data dir) so nothing has to
-- be installed system-wide: mason.setup() prepends its bin dir to nvim's PATH.
local languages = { "rust", "lua", "javascript", "typescript", "tsx", "yuck" }

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        dependencies = { "mason-org/mason.nvim" },
        config = function()
            local mason = require "mason"
            if not mason.has_setup then
                mason.setup {}
            end

            -- Highlighting only (indentation handled elsewhere).
            vim.api.nvim_create_autocmd("FileType", {
                pattern = "*",
                callback = function(args)
                    if vim.bo[args.buf].buftype ~= "" then
                        return
                    end
                    pcall(vim.treesitter.start, args.buf)
                end,
            })

            local function install_parsers()
                require("nvim-treesitter").install(languages)
            end

            -- Ensure the tree-sitter CLI exists before building parsers.
            local registry = require "mason-registry"
            local ok, pkg = pcall(registry.get_package, "tree-sitter-cli")
            if not ok then
                vim.notify("[nvim-treesitter] tree-sitter-cli not in mason registry", vim.log.levels.ERROR)
            elseif pkg:is_installed() then
                install_parsers()
            else
                pkg:install(nil, vim.schedule_wrap(function(success)
                    if success then
                        install_parsers()
                    else
                        vim.notify("[nvim-treesitter] tree-sitter-cli install failed", vim.log.levels.ERROR)
                    end
                end))
            end
        end
    }
}
