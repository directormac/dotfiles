return {
    {
        "nvim-treesitter/nvim-treesitter",
        depends = {
            "nvim-treesitter/nvim-treesitter-context",
        },
        lazy = false,
        build = ":TSUpdate",
        opts_extend = { "ensure_installed" },
        opts = {
            auto_install = true,
            sync_install = false,
            highlight = { enable = true },
            indent = { enable = true },
            incremental_selection = {
                enable = true,
                keymaps = {
                    init_selection = "<Enter>", -- set to `false` to disable one of the mappings
                    node_incremental = "<Enter>",
                    scope_incremental = false,
                    node_decremental = "<Backspace>",
                },
            },
            ensure_installed = {
                "bash",
                "c",
                "diff",
                "html",
                "javascript",
                "jsdoc",
                "json",
                "lua",
                "luadoc",
                "luap",
                "markdown",
                "markdown_inline",
                "printf",
                "python",
                "query",
                "regex",
                "toml",
                "tsx",
                "typescript",
                "vim",
                "vimdoc",
                "xml",
                "yaml",
            },
        },
        config = function(_, opts)
            local TS = require("nvim-treesitter")

            if not TS.get_installed then
                return
            end

            TS.setup(opts)

            TS.get_installed(true)
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        opts = {
            move = {
                enable = true,
                set_jumps = true, -- whether to set jumps in the jumplist
                -- LazyVim extention to create buffer-local keymaps
                keys = {
                    goto_next_start = {
                        ["]f"] = "@function.outer",
                        ["]c"] = "@class.outer",
                        ["]a"] = "@parameter.inner",
                    },
                    goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
                    goto_previous_start = {
                        ["[f"] = "@function.outer",
                        ["[c"] = "@class.outer",
                        ["[a"] = "@parameter.inner",
                    },
                    goto_previous_end = {
                        ["[F"] = "@function.outer",
                        ["[C"] = "@class.outer",
                        ["[A"] = "@parameter.inner",
                    },
                },
            },
            select = {
                enable = true,

                -- Automatically jump forward to textobj, similar to targets.vim
                lookahead = true,

                keymaps = {
                    -- You can use the capture groups defined in textobjects.scm
                    ["af"] = "@function.outer",
                    ["if"] = "@function.inner",
                    ["ac"] = "@class.outer",
                    ["ao"] = "@comment.outer",
                    -- You can optionally set descriptions to the mappings (used in the desc parameter of
                    -- nvim_buf_set_keymap) which plugins like which-key display
                    ["ic"] = { query = "@class.inner", desc = "Select inner part of a class region" },
                    -- You can also use captures from other query groups like `locals.scm`
                    ["as"] = { query = "@local.scope", query_group = "locals", desc = "Select language scope" },
                },
                -- You can choose the select mode (default is charwise 'v')
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * method: eg 'v' or 'o'
                -- and should return the mode ('v', 'V', or '<c-v>') or a table
                -- mapping query_strings to modes.
                selection_modes = {
                    ["@parameter.outer"] = "v", -- charwise
                    ["@function.outer"] = "V", -- linewise
                    ["@class.outer"] = "<c-v>", -- blockwise
                },
                -- If you set this to `true` (default is `false`) then any textobject is
                -- extended to include preceding or succeeding whitespace. Succeeding
                -- whitespace has priority in order to act similarly to eg the built-in
                -- `ap`.
                --
                -- Can also be a function which gets passed a table with the keys
                -- * query_string: eg '@function.inner'
                -- * selection_mode: eg 'v'
                -- and should return true or false
                include_surrounding_whitespace = true,
            },
            swap = {
                enable = true,
                swap_next = {
                    ["<leader>a"] = { query = "@parameter.inner", desc = "Swap with next parameter" },
                },
                swap_previous = {
                    ["<leader>A"] = "@parameter.inner",
                },
            },
        },
        -- init = function()
        --     -- Disable entire built-in ftplugin mappings to avoid conflicts.
        --     -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
        --     vim.g.no_plugin_maps = true
        --
        --     -- Or, disable per filetype (add as you like)
        --     -- vim.g.no_python_maps = true
        --     -- vim.g.no_ruby_maps = true
        --     -- vim.g.no_rust_maps = true
        --     -- vim.g.no_go_maps = true
        -- end,
        config = function(_, opts)
            local TSobs = require("nvim-treesitter-textobjects")
            local TS = require("nvim-treesitter")

            if not TSobs.get_installed then
                return
            end

            TSobs.setup(opts)

            local function attach(buf)
                local ft = vim.bo[buf].filetype
                if not (vim.tbl_get(opts, "move", "enable") and TS.get_installed("textobjects", buf)) then
                    return
                end
                ---@type table<string, table<string, string>>
                local moves = vim.tbl_get(opts, "move", "keys") or {}

                for method, keymaps in pairs(moves) do
                    for key, query in pairs(keymaps) do
                        local queries = type(query) == "table" and query or { query }
                        local parts = {}
                        for _, q in ipairs(queries) do
                            local part = q:gsub("@", ""):gsub("%..*", "")
                            part = part:sub(1, 1):upper() .. part:sub(2)
                            table.insert(parts, part)
                        end
                        local desc = table.concat(parts, " or ")
                        desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
                        desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
                        vim.keymap.set({ "n", "x", "o" }, key, function()
                            if vim.wo.diff and key:find("[cC]") then
                                return vim.cmd("normal! " .. key)
                            end
                            require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
                        end, {
                            buffer = buf,
                            desc = desc,
                            silent = true,
                        })
                    end
                end
            end

            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter_textobjects", { clear = true }),
                callback = function(ev)
                    attach(ev.buf)
                end,
            })

            vim.tbl_map(attach, vim.api.nvim_list_bufs())
        end,
    },
    {
        "windwp/nvim-ts-autotag",
        enabled = true,
        ft = { "html", "xml", "javascript", "typescript", "javascriptreact", "typescriptreact", "svelte" },
        config = function()
            require("nvim-ts-autotag").setup({
                opts = {
                    enable_close = true, -- Auto-close tags
                    enable_rename = true, -- Auto-rename pairs
                    enable_close_on_slash = false, -- Disable auto-close on trailing `</`
                },
                per_filetype = {
                    ["html"] = {
                        enable_close = true,
                    },
                    ["typescriptreact"] = {
                        enable_close = true,
                    },
                },
            })
        end,
    },
}


