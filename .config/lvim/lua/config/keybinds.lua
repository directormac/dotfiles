local function diffview_toggle(cmd)
    local diffview_open = false

    -- Iterate through all tabs
    for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
        -- Get windows in this tab
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
            local buf = vim.api.nvim_win_get_buf(win)
            local buf_name = vim.api.nvim_buf_get_name(buf)

            if buf_name:match("^diffview") then
                diffview_open = true
                break
            end
        end
        if diffview_open then break end
    end

    if diffview_open then
        vim.cmd [[DiffviewClose]]
    else
        vim.cmd(cmd)
    end
end

local function diffview_toggle_open()
    diffview_toggle [[DiffviewOpen]]
end

local function diffview_toggle_file_history()
    diffview_toggle [[DiffviewFileHistory]]
end

local function telescope_file_browser(opts)
    vim.cmd [[DiffviewClose]]
    require("telescope").extensions.file_browser.file_browser(opts)
end

local function telescope_find_files(opts)
    vim.cmd [[DiffviewClose]]
    require("telescope.builtin").find_files(opts)
end

local function telescope_live_grep(opts)
    vim.cmd [[DiffviewClose]]
    require("telescope.builtin").live_grep(opts)
end

local function telescope_help_tags(opts)
    require("telescope.builtin").help_tags(opts)
end

local function telescope_highlights(opts)
    require("telescope.builtin").highlights(opts)
end

local function telescope_keymaps(opts)
    require("telescope.builtin").keymaps(opts)
end

-- Base Telescope
local function telescope_refresh(bufnr)
    local actions = require "telescope.actions"

    actions.refresh(bufnr)
end

local function telescope_vsplit(bufnr)
    local actions = require "telescope.actions"

    actions.select_vertical(bufnr)
end

local function telescope_hsplit(bufnr)
    local actions = require "telescope.actions"

    actions.select_horizontal(bufnr)
end

-- Telescope file browser
local function telescope_file_browser_goto_parent_dir(bufnr)
    local actions = require "telescope".extensions.file_browser.actions

    actions.goto_parent_dir(bufnr)
end

local function telescope_file_browser_toggle_hidden(bufnr)
    local actions = require "telescope".extensions.file_browser.actions

    actions.toggle_hidden(bufnr)
end

local function telescope_file_browser_toggle_respect_gitignore(bufnr)
    local actions = require "telescope".extensions.file_browser.actions

    actions.toggle_respect_gitignore(bufnr)
end


local function telescope_file_browser_remove(bufnr)
    local actions = require "telescope".extensions.file_browser.actions

    actions.remove(bufnr)
end

local function telescope_file_browser_copy(bufnr)
    local actions = require "telescope".extensions.file_browser.actions

    actions.copy(bufnr)
end

local function telescope_file_browser_rename(bufnr)
    local actions = require "telescope".extensions.file_browser.actions

    actions.rename(bufnr)
end

local function telescope_file_browser_create(bufnr)
    local actions = require "telescope".extensions.file_browser.actions

    actions.create(bufnr)
end

-- LSP
local function custom_goto_prev(severity)
    return function()
        vim.diagnostic.goto_prev { severity = severity }
    end
end

local function custom_goto_next(severity)
    return function()
        vim.diagnostic.goto_next { severity = severity }
    end
end

local prev_error = custom_goto_prev(vim.diagnostic.severity.ERROR)
local next_error = custom_goto_next(vim.diagnostic.severity.ERROR)

local prev_warn = custom_goto_prev(vim.diagnostic.severity.WARN)
local next_warn = custom_goto_next(vim.diagnostic.severity.WARN)

local prev_info = custom_goto_prev(vim.diagnostic.severity.INFO)
local next_info = custom_goto_next(vim.diagnostic.severity.INFO)

local next_hint = custom_goto_prev(vim.diagnostic.severity.HINT)
local prev_hint = custom_goto_next(vim.diagnostic.severity.HINT)

local lsp_implementations = function()
    require("telescope.builtin").lsp_implementations()
end

local lsp_references = function()
    require("telescope.builtin").lsp_references({ trim_text = true, include_declaration = false, })
end

local hover = function()
    -- Extends `vim.lsp.util.open_floating_preview.Opts`
    vim.lsp.buf.hover {
        max_width = 50,
    }
end

local M = {}

-- Neovim keybinds that collide with our custom keybinds in some way
M.remove = {
    'grn', 'gri', 'grr', 'grt', 'gra', -- LSP
}

-- General system keybinds
M.system = {
    -- Disable mouse right click
    { mode = { "n", "i", "v" }, keymap = "<RightMouse>",    action = "<nop>" },

    -- WhichKey
    { mode = "n",               keymap = "<leader><Space>", action = "<cmd>WhichKey<CR>",                     desc = "List all keybinds", },

    -- Resize panes
    { mode = "n",               keymap = "<C-Up>",          action = "<cmd>resize -2<CR>",                    desc = "Resize windows", },
    { mode = "n",               keymap = "<C-Down>",        action = "<cmd>resize +2<CR>",                    desc = "Resize windows", },
    { mode = "n",               keymap = "<C-Left>",        action = "<cmd>vertical resize -2<CR>",           desc = "Resize windows", },
    { mode = "n",               keymap = "<C-Right>",       action = "<cmd>vertical resize +2<CR>",           desc = "Resize windows", },

    -- Navigate Panes
    { mode = "n",               keymap = "<c-k>",           action = "<C-w>k",                                desc = "Navigate to window above", },
    { mode = "n",               keymap = "<c-j>",           action = "<C-w>j",                                desc = "Navigate to window below", },
    { mode = "n",               keymap = "<c-h>",           action = "<C-w>h",                                desc = "Navigate to left window", },
    { mode = "n",               keymap = "<c-l>",           action = "<C-w>l",                                desc = "Navigate to right window", },

    -- Paste without clobbering clipboard
    { mode = "x",               keymap = "p",               action = "pgvy",                                  desc = "Paste without clobbering clipboard", },

    -- Clear search highlighting
    { mode = "n",               keymap = "<Esc>",           action = ":noh<CR>",                              desc = "clear search highlight", },

    -- Stay in visual mode after indenting
    { mode = "v",               keymap = "<",               action = "<gv",                                   desc = "indent less", },
    { mode = "v",               keymap = ">",               action = ">gv",                                   desc = "indent more", },

    -- Copy to system clipboard in visual/visual block mode
    { mode = "v",               keymap = "<c-y>",           action = '"+y',                                   desc = "copy to system clipboard", },
    { mode = "x",               keymap = "<c-y>",           action = '"+y',                                   desc = "copy to system clipboard", },

    -- Diffview
    { mode = "n",               keymap = "<leader>dd",      action = diffview_toggle_open,                    desc = "Diffview Toggle", },
    { mode = "n",               keymap = "<leader>dr",      action = "<cmd>DiffviewRefresh<CR>",              desc = "[D]iffview [R]efresh", },
    { mode = "n",               keymap = "<leader>dh",      action = diffview_toggle_file_history,            desc = "[D]iffview File [H]istory", },

    -- Gitsigns
    { mode = "n",               keymap = "[g",              action = "<cmd>Gitsigns prev_hunk<CR>",           desc = "[g]it Previous Hunk", },
    { mode = "n",               keymap = "]g",              action = "<cmd>Gitsigns next_hunk<CR>",           desc = "[g]it Next Hunk", },
    { mode = "n",               keymap = "<leader>gs",      action = "<cmd>Gitsigns stage_hunk<CR>",          desc = "[g]it [s]tage hunk", },
    { mode = "n",               keymap = "<leader>gr",      action = "<cmd>Gitsigns reset_hunk<CR>",          desc = "[g]it [r]eset hunk", },
    { mode = "n",               keymap = "<leader>gS",      action = "<cmd>Gitsigns undo_stage_hunk<CR>",     desc = "[g]it undo [S]tage hunk", },
    { mode = "n",               keymap = "<leader>gp",      action = "<cmd>Gitsigns preview_hunk_inline<CR>", desc = "[g]it [p]review hunk", },

    -- Telescope
    { mode = "n",               keymap = "<leader>t",       action = telescope_file_browser,                  desc = "Telescope File Browser", },
    { mode = "n",               keymap = "<leader>f",       action = telescope_find_files,                    desc = "Telescope [f]ile Search", },
    { mode = "n",               keymap = "<leader>l",       action = telescope_live_grep,                     desc = "Telescope [l]ive Grep", },
    { mode = "n",               keymap = "<leader>ut",      action = telescope_help_tags,                     desc = "Telescope [u]itl help [t]ags", },
    { mode = "n",               keymap = "<leader>uh",      action = telescope_highlights,                    desc = "Telescope [u]til [h]ighlights", },
    { mode = "n",               keymap = "<leader>uk",      action = telescope_keymaps,                       desc = "Telescope [u]til [k]eybinds", },
}

-- Telescope keybinds
M.telescope = {
    i = {},
    n = {
        R = telescope_refresh,
        ["<c-i>"] = telescope_vsplit,
        ["<c-o>"] = telescope_hsplit,
    },
}

-- Telescope file browser keybinds
M.telescope_file_browser = {
    i = {},
    n = {
        l = "select_default",
        h = telescope_file_browser_goto_parent_dir,
        H = telescope_file_browser_toggle_hidden,
        I = telescope_file_browser_toggle_respect_gitignore,

        d = telescope_file_browser_remove,
        y = telescope_file_browser_copy,
        r = telescope_file_browser_rename,
        a = telescope_file_browser_create,
    },
}

-- LSP Keybinds
M.lsp = {
    { mode = "n", keymap = "gd",         action = vim.lsp.buf.definition,    desc = "[g]oto [d]efinition", },
    { mode = "n", keymap = "K",          action = hover,                     desc = "Get object Info", },
    { mode = "n", keymap = "gi",         action = lsp_implementations,       desc = "[g]et [i]mplementation", },
    { mode = "n", keymap = "<leader>rn", action = vim.lsp.buf.rename,        desc = "[r]e[n]ame" },
    { mode = "n", keymap = "gr",         action = lsp_references,            desc = "[g]et [r]eferences", },
    { mode = "n", keymap = "<leader>ca", action = vim.lsp.buf.code_action,   desc = "[c]ode [a]ctions", },
    { mode = "n", keymap = "<leader>e",  action = vim.diagnostic.open_float, desc = "Display info about errors", },

    { mode = "n", keymap = "[d",         action = vim.diagnostic.goto_prev,  desc = "Prev Def" },
    { mode = "n", keymap = "]d",         action = vim.diagnostic.goto_next,  desc = "Next Def" },

    { mode = "n", keymap = "[e",         action = prev_error,                desc = "Prev Error" },
    { mode = "n", keymap = "]e",         action = next_error,                desc = "Next Error" },

    { mode = "n", keymap = "[w",         action = prev_warn,                 desc = "Prev Warning", },
    { mode = "n", keymap = "]w",         action = next_warn,                 desc = "Next Warning", },

    { mode = "n", keymap = "[i",         action = prev_info,                 desc = "Prev Info" },
    { mode = "n", keymap = "]i",         action = next_info,                 desc = "Next Info" },

    { mode = "n", keymap = "[h",         action = prev_hint,                 desc = "Prev Hint" },
    { mode = "n", keymap = "]h",         action = next_hint,                 desc = "Next Hint" },
}

return M
