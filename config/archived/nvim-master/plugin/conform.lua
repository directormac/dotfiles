require('lazyload').on_vim_enter(function()
  vim.g.auto_format = true

  vim.pack.add({
    { src = 'https://github.com/stevearc/conform.nvim' },
  })

  require('conform').setup({
    format_on_save = function()
      if not vim.g.auto_format then return end
      return { timeout_ms = 5000, lsp_format = 'fallback' }
    end,
    formatters_by_ft = {
      elixir = { 'mix' },
      lua = { 'stylua' },
      fish = { 'fish_indent' },
      sh = { 'shfmt' },
    },

    -- The options you set here will be merged with the builtin formatters.
    -- You can also define any custom formatters here.
    ---@type table<string, conform.FormatterConfigOverride|fun(bufnr: integer): nil|conform.FormatterConfigOverride>
    formatters = {
      injected = { options = { ignore_errors = true } },
      -- # Example of using dprint only when a dprint.json file is present
      -- dprint = {
      --   condition = function(ctx)
      --     return vim.fs.find({ "dprint.json" }, { path = ctx.filename, upward = true })[1]
      --   end,
      -- },
      --
      -- # Example of using shfmt with extra args
      -- shfmt = {
      --   prepend_args = { "-i", "2", "-ci" },
      -- },
    },
    default_format_opts = {
      timeout_ms = 3000,
      async = false,
      quiet = false,
      lsp_format = 'fallback',
    },
  })

  vim.keymap.set(
    { 'n', 'x' },
    '<leader>cF',
    function() require('conform').format({ formatters = { 'injected' }, timeout_ms = 3000 }) end,
    {

      desc = 'Format Injected Langs',
    }
  )

  vim.keymap.set('n', '<leader>uf', function()
    vim.g.auto_format = not vim.g.auto_format
    vim.notify('Auto-format: ' .. (vim.g.auto_format and 'on' or 'off'))
  end, { desc = 'Toggle auto-format' })
end)

-- vim.pack.add({ 'https://github.com/stevearc/conform.nvim' })
--
-- require('conform').setup({
--   notify_on_error = false,
--   format_on_save = function(bufnr)
--     -- You can specify filetypes to autoformat on save here:
--     local enabled_filetypes = {
--       lua = true,
--       taplo = true,
--     }
--     if enabled_filetypes[vim.bo[bufnr].filetype] then
--       return { timeout_ms = 500 }
--     else
--       return nil
--     end
--   end,
--   default_format_opts = {
--     lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
--   },
--   -- You can also specify external formatters in here.
--   formatters_by_ft = {
--     lua = { 'stylua' },
--     toml = { 'taplo' },
--     -- rust = { 'rustfmt' },
--     -- Conform can also run multiple formatters sequentially
--     -- python = { "isort", "black" },
--     --
--     -- You can use 'stop_after_first' to run the first available formatter from the list
--     -- javascript = { "prettierd", "prettier", stop_after_first = true },
--   },
-- })
--
-- vim.keymap.set(
--   { 'n', 'v' },
--   '<leader>cf',
--   function() require('conform').format({ async = true }) end,
--   { desc = 'Format buffer.' }
-- )
