return {
    {
        'nvim-telescope/telescope-ui-select.nvim',
        dependencies = { "nvim-telescope/telescope.nvim" }
    },
    {
        "nvim-telescope/telescope-file-browser.nvim",
        dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" }
    },
    {
        "nvim-telescope/telescope.nvim",
        event = { "VeryLazy" },
        branch = "master",
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            local netrw_bufname

            -- See: https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/626998e5c1b71c130d8bc6cf7abb6709b98287bb/lua/telescope/_extensions/file_browser/config.lua#L73
            pcall(vim.api.nvim_clear_autocmds, { group = "NvimLiteFindFiles" })
            vim.api.nvim_create_autocmd("VimEnter", {
                pattern = "*",
                once = true,
                callback = function()
                    pcall(vim.api.nvim_clear_autocmds, { group = "FileExplorer" })
                end,
            })
            vim.api.nvim_create_autocmd("BufEnter", {
                group = vim.api.nvim_create_augroup("NvimLiteFindFiles", { clear = true }),
                pattern = "*",
                callback = function()
                    vim.schedule(function()
                        if vim.bo[0].filetype == "netrw" then
                            return
                        end
                        local bufname = vim.api.nvim_buf_get_name(0)
                        if vim.fn.isdirectory(bufname) == 0 then
                            _, netrw_bufname = pcall(vim.fn.expand, "#:p:h")
                            return
                        end

                        -- prevents reopening of file-browser if exiting without selecting a file
                        if netrw_bufname == bufname then
                            netrw_bufname = nil
                            return
                        else
                            netrw_bufname = bufname
                        end

                        -- ensure no buffers remain with the directory name
                        vim.api.nvim_buf_set_option(0, "bufhidden", "wipe")

                        require("telescope.builtin").find_files({
                            cwd = vim.fn.expand("%:p:h"),
                        })
                    end)
                end,
                desc = "telescope find files replacement for netrw",
            })

            local keybinds = require "config.keybinds"
            require("telescope").setup({
                defaults = {
                    selection_caret = " ",
                    entry_prefix = " ",
                    prompt_prefix = "    ",
                    initial_mode = "insert",
                    sorting_strategy = "ascending",
                    layout_strategy = "horizontal",
                    layout_config = {
                        horizontal = {
                            prompt_position = "top",
                            preview_width = 0.55,
                            results_width = 0.3,
                        },

                        vertical = {
                            mirror = false,
                        },

                        -- width and height of telescope
                        width = 0.8,
                        height = 0.7,

                        preview_cutoff = 120,
                    },
                    file_ignore_patterns = { "node_modules" },
                    mappings = keybinds.telescope,
                },
                pickers = {
                    find_files = { theme = "dropdown" },
                    live_grep = { theme = "ivy" }
                },
                extensions = {
                    file_browser = {
                        theme = "dropdown",
                        hide_parent_dir = true,
                        grouped = true,
                        sorting_strategy = "ascending",
                        initial_mode = "normal",
                        mappings = keybinds.telescope_file_browser,
                    },
                },
            })

            require("telescope").load_extension "file_browser"

            require("telescope").load_extension "ui-select"
        end
    },
}
