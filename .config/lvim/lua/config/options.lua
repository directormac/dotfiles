-- File handling
vim.opt.backup = false         -- Disables creation of backup files
vim.opt.swapfile = false       -- Prevents creation of .swp swap files
vim.opt.undofile = true        -- Maintains undo history between sessions
vim.opt.fileencoding = "utf-8" -- Sets the encoding used when writing files

-- User interface
vim.opt.laststatus = 3  -- Uses global status line instead of one per window
vim.opt.showtabline = 0 -- Never show the tab line

-- Searching
vim.opt.ignorecase = true -- Ignores case when searching
vim.opt.smartcase = true  -- Overrides ignorecase when search includes uppercase

-- Editing and indentation
vim.opt.smartindent = true -- Automatically adjusts indent for certain languages
vim.opt.expandtab = true   -- Converts tabs to spaces
vim.opt.tabstop = 4        -- Sets how many spaces a tab character represents
vim.opt.shiftwidth = 4
vim.opt.timeoutlen = 300   -- Sets wait time for mapped key sequences in milliseconds
vim.opt.updatetime = 300   -- Controls swap file writing and plugin update frequency

-- Display and layout
vim.opt.number = true          -- Shows line numbers
vim.opt.relativenumber = false -- Uses absolute rather than relative line numbers
vim.opt.signcolumn = "yes"     -- Always shows the sign column for diagnostics
vim.opt.wrap = false           -- Prevents lines from wrapping
vim.opt.linebreak = false      -- Would preserve words when wrapping (if wrap was enabled)
vim.opt.tw = 80                -- Sets text width for automatic wrapping

-- Window management
vim.opt.splitbelow = true -- Opens horizontal splits below current window
vim.opt.splitright = true -- Opens vertical splits to the right of current window

-- Folding
vim.opt.foldmethod = "indent" -- Creates folds based on indentation levels
vim.opt.foldlevel = 9

-- Additional settings
vim.opt.shortmess:append "c" -- Suppresses completion-menu messages

-- hide tildes at end of buffers
vim.cmd [[ set fillchars=eob:\ ]]

-- diff now uses ╱
vim.cmd [[ set fillchars+=diff:╱ ]]

vim.api.nvim_create_autocmd("VimResized", {
    pattern = "*",
    callback = function()
        vim.cmd("wincmd =")
    end,
})
