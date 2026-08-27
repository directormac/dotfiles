return {
    {
        "hrsh7th/nvim-cmp",
        event = { "VeryLazy" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "saadparwaiz1/cmp_luasnip",
            "onsails/lspkind.nvim",
            "L3MON4D3/LuaSnip"
        },
        config = function()
            local luasnip = require "luasnip"
            local cmp = require "cmp"

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body) -- For `luasnip` users.
                    end,
                },

                window = {
                    completion = {
                        winhighlight = "Normal:Pmenu,CursorLine:CmpItemSel,FloatBorder:Pmenu,Search:None",
                        col_offset = -3,
                        side_padding = 0,
                    },
                    documentation = {
                        winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
                    },
                },
                mapping = {
                    -- scroll through the subwindow provided by cmp with `ctrl + j/k`
                    ["<C-k>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
                    ["<C-j>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),

                    -- pulls up autocompletion menu without needing to type
                    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),

                    -- `enter` selects the current item
                    ["<CR>"] = cmp.mapping.confirm { select = true },

                    -- `tab` cycles through the options
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        else
                            fallback()
                        end
                    end, {
                        "i",
                        "s",
                    }),

                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        else
                            fallback()
                        end
                    end, {
                        "i",
                        "s",
                    }),
                },
                formatting = {
                    fields = { "kind", "abbr", "menu" },
                    format = function(entry, vim_item)
                        local old_kind = vim_item.kind

                        local format = require("lspkind").cmp_format {
                            mode = "symbol",
                            ellipsis_char = '…',
                            preset = "codicons",
                            symbol_map = {
                                Text = "󰉿",
                                Method = "󰆧",
                                Function = "󰊕",
                                Constructor = "",
                                Field = "󰜢",
                                Variable = "󰀫",
                                Class = "󰠱",
                                Interface = "",
                                Module = "",
                                Property = "󰜢",
                                Unit = "󰑭",
                                Value = "󰎠",
                                Enum = "",
                                Keyword = "󰌋",
                                Snippet = "",
                                Color = "󰏘",
                                File = "󰈙",
                                Reference = "󰈇",
                                Folder = "󰉋",
                                EnumMember = "",
                                Constant = "󰏿",
                                Struct = "󰙅",
                                Event = "",
                                Operator = "󰆕",
                                TypeParameter = "󰀫",
                            },
                            menu = {
                                nvim_lsp = "[lsp]",
                                nvim_lua = "[lua]",
                                luasnip = "[luasnip]",
                                npm = "[npm]",
                                buffer = "[buf]",
                                path = "[path]",
                                cmdline = "[cmd]",
                            },
                            maxwidth = {
                                menu = 50,
                                abbr = 30
                            },
                        }

                        local vim_item = format(entry, vim_item)
                        local strings = vim.split(vim_item.kind, "%s", { trimempty = true })

                        if vim_item.menu == "[minuet]" then
                            vim_item.kind = " 󰊕 "
                        else
                            vim_item.kind = " " .. (strings[1] or "") .. " "
                        end

                        vim_item.menu = old_kind

                        return vim_item
                    end,
                },
                sources = {
                    { name = "minuet" },
                    { name = "nvim_lsp" },
                    { name = "luasnip" },
                    { name = "buffer" },
                    { name = "path" },
                },
                confirm_opts = {
                    behavior = cmp.ConfirmBehavior.Replace,
                    select = false,
                },
            })
        end
    },
}
