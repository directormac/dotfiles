require "config.options"

require "config.lazy"

local keybinds = require "config.keybinds"

-- remove conflicting keybinds
for _, km in ipairs(keybinds.remove) do
    pcall(vim.keymap.del, 'n', km)
end

-- set keymaps
for _, km in ipairs(keybinds.system) do
    vim.keymap.set(km.mode, km.keymap, km.action, { noremap = true, silent = true, desc = km.desc })
end
