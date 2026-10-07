-- Formatting, linting and surrounding.
return {
  {
    'conform.nvim',
    auto_enable = true,
    -- cmd = { "" },
    -- event = "",
    -- ft = "",
    keys = {
      { '<leader>FF', desc = '[F]ormat [F]ile' },
    },
    -- colorscheme = "",
    after = function(plugin)
      local conform = require('conform')

      conform.setup({
        formatters_by_ft = {
          -- NOTE: add some formatters in your specs' runtimePkgs
          -- and configure them here
          lua = nixInfo(nil, 'settings', 'cats', 'lua') and { 'stylua' } or nil,
          -- go = { "gofmt", "golint" },
          -- templ = { "templ" },
          -- Conform will run multiple formatters sequentially
          -- python = { "isort", "black" },
          -- Use a sub-list to run only the first available formatter
          -- javascript = { { "prettierd", "prettier" } },
        },
      })

      vim.keymap.set(
        { 'n', 'v' },
        '<leader>FF',
        function()
          conform.format({
            lsp_fallback = true,
            async = false,
            timeout_ms = 1000,
          })
        end,
        { desc = '[F]ormat [F]ile' }
      )
    end,
  },
  {
    'nvim-lint',
    auto_enable = true,
    -- cmd = { "" },
    event = 'FileType',
    -- ft = "",
    -- keys = "",
    -- colorscheme = "",
    after = function(plugin)
      require('lint').linters_by_ft = {
        -- NOTE: add some linters in your specs' runtimePkgs
        -- and configure them here
        -- markdown = {'vale',},
        -- javascript = { 'eslint' },
        -- typescript = { 'eslint' },
      }

      vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        callback = function() require('lint').try_lint() end,
      })
    end,
  },
  {
    'nvim-surround',
    auto_enable = true,
    event = 'DeferredUIEnter',
    -- keys = "",
    after = function(plugin) require('nvim-surround').setup() end,
  },
}
