-- Early return so this file is ignored by the config loader
if true then return end

---@type lz.n.Plugin[]
local example_specs = {
  {
    "plugin-name/repository", -- The plugin repository (or just name if managed by Nix)
    
    -- --- 1. Load Control ---
    -- auto_enable: When true, forces the plugin spec to be evaluated.
    -- If false/omitted, the plugin won't load unless it's a dependency of another plugin.
    auto_enable = true,
    
    -- lazy: Force lazy loading. Usually inferred by the presence of `event`, `cmd`, etc.
    lazy = true,
    
    -- --- 2. Lazy Loading Triggers ---
    -- Load on specific Neovim events (e.g., 'BufReadPre', 'DeferredUIEnter')
    event = { "DeferredUIEnter" }, 
    
    -- Load when specific commands are executed
    cmd = { "MyCommand", "MyOtherCommand" },
    
    -- Load for specific filetypes
    ft = { "lua", "python" },
    
    -- Load when a keymap is pressed
    keys = {
      { "<leader>p", "<cmd>MyCommand<cr>", desc = "Run MyCommand" },
    },
    
    -- --- 3. Dependencies & Ordering ---
    -- Load this plugin immediately AFTER 'other-plugin' is loaded
    on_plugin = { "other-plugin" },
    
    -- Treat this plugin as a dependency of 'parent-plugin'. 
    -- It will load just before 'parent-plugin'.
    dep_of = { "parent-plugin" },
    
    -- Only load if this colorscheme is active
    colorscheme = "catppuccin",
    
    -- --- 4. Hooks / Handlers ---
    -- Runs BEFORE the plugin is loaded
    before = function(plugin)
      vim.g.my_plugin_config = true
    end,
    
    -- Custom loader function (overrides default lazy loading)
    load = function(plugin)
      -- custom loading logic
    end,
    
    -- Runs AFTER the plugin is loaded (used for setup)
    after = function(plugin)
      require("plugin-name").setup({
        -- options here
      })
    end,
  }
}
