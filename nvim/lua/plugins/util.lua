-- vim.o.showcmdloc = "statusline"
-- vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"
--
--

return {
  {
    "stevearc/oil.nvim",
    opts = {
      use_default_keymaps = false,
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = "none",
        ["<C-h>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["g."] = "actions.toggle_hidden",
      },
    },
    -- Optional dependencies
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },
  {
    "m4xshen/hardtime.nvim",
    opts = {
      max_time = 1000,
      max_count = 2,
      disable_mouse = false,
      hint = true,
      allow_different_key = false,
      resetting_keys = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "c", "d" },
      restricted_keys = { "h", "j", "k", "l", "-", "+", "<UP>", "<DOWN>", "<LEFT>", "<RIGHT>" },
      hint_keys = { "k", "j", "^", "$", "a", "x", "i", "d", "y", "c", "l" },
      disabled_keys = { "<UP>", "<DOWN>", "<LEFT>", "<RIGHT>" },
      disabled_filetypes = { "lazy", "mason" },
    },
  },
  {

    "williamboman/mason.nvim",
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "marksman")
      table.insert(opts.ensure_installed, "grammarly-languageserver")
      table.insert(opts.ensure_installed, "codelldb")
      table.insert(opts.ensure_installed, "rust-analyzer")
      table.insert(opts.ensure_installed, "rustfmt")
      table.insert(opts.ensure_installed, "svelte-language-server")
      table.insert(opts.ensure_installed, "typescript-language-server")
      table.insert(opts.ensure_installed, "vue-language-server")
      table.insert(opts.ensure_installed, "prettierd")
      table.insert(opts.ensure_installed, "html-lsp")
      table.insert(opts.ensure_installed, "css-lsp")
      table.insert(opts.ensure_installed, "eslint-lsp")
      table.insert(opts.ensure_installed, "eslint_d")
      table.insert(opts.ensure_installed, "astro-language-server")
      table.insert(opts.ensure_installed, "zls")
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    cmd = {
      "TSBufDisable",
      "TSBufEnable",
      "TSBufToggle",
      "TSDisable",
      "TSEnable",
      "TSToggle",
      "TSInstall",
      "TSInstallInfo",
      "TSInstallSync",
      "TSModuleInfo",
      "TSUninstall",
      "TSUpdate",
      "TSUpdateSync",
    },
    opts = function(_, opts)
      table.insert(opts.ensure_installed, "html")
      table.insert(opts.ensure_installed, "javascript")
      table.insert(opts.ensure_installed, "css")
      table.insert(opts.ensure_installed, "json")
      table.insert(opts.ensure_installed, "typescript")
      table.insert(opts.ensure_installed, "svelte")
      table.insert(opts.ensure_installed, "vue")
      table.insert(opts.ensure_installed, "tsx")
      table.insert(opts.ensure_installed, "rust")
      table.insert(opts.ensure_installed, "markdown")
      table.insert(opts.ensure_installed, "markdown_inline")
      table.insert(opts.ensure_installed, "toml")
      table.insert(opts.ensure_installed, "lua")
    end,
  },
}
