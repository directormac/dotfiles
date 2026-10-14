return {
  {
    'SchemaStore.nvim',
    ft = { 'json', 'jsonc', 'yaml' },
    on_require = { 'schemastore' },
    after = function()
      -- https://github.com/b0o/SchemaStore.nvim
      vim.lsp.config('jsonls', {
        settings = {
          json = {
            schemas = require('schemastore').json.schemas(),
            validate = { enable = true },
          },
        },
      })

      vim.lsp.config('yamlls', {
        settings = {
          yaml = {
            schemaStore = {
              -- You must disable built-in schemaStore support if you want to use
              -- this plugin and its advanced options like `ignore`.
              enable = false,
              -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
              url = '',
            },
            schemas = require('schemastore').yaml.schemas(),
          },
        },
      })
    end,
  },
}
