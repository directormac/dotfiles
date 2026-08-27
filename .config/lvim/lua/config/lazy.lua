-- Bootstrap lazy.nvim
local install_path = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(install_path) then
    local repo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        repo,
        install_path,
    }
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out,                            "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(install_path)

local status_ok, lazy = pcall(require, "lazy")
if not status_ok then
    return
end

-- LEADER KEY: <Space>
vim.api.nvim_set_keymap("", "<Space>", "<Nop>", { noremap = true, silent = true })
vim.g.mapleader = " "

lazy.setup {
    spec = {
        { import = "plugins" }
    },

    -- Automatically check for plugin updates
    checker = { enabled = false },

    change_detection = {
        enabled = false,
        notify = false,
    }
}
