-- https://github.com/llGaetanll/nvim-lite
--
-- local function on_attach(client, bufnr)
--   -- LSP key bindings
--   -- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/formatting.lua
--   local keymaps = require "config.keymaps"
--
--   for _, km in ipairs(lsp) do
--     vim.keymap.set(
--       km.mode,
--       km.keymap,
--       km.action,
--       { buffer = bufnr, noremap = true, silent = true, desc = "[LSP]: " .. km.desc }
--     )
--   end
--
--
--   -- Format on save
--   if client.name == "ts_ls" then
--     vim.api.nvim_create_autocmd("BufWritePost", {
--       buffer = bufnr,
--       callback = function()
--         local filepath = vim.fn.expand("%:p")
--         vim.fn.jobstart({ "prettier", "--write", filepath }, {
--           on_exit = function()
--             -- Reload the buffer to show formatting changes
--             vim.cmd("checktime")
--           end
--         })
--       end
--     })
--   else
--     vim.api.nvim_create_autocmd("BufWritePre", {
--       buffer = bufnr,
--       callback = function()
--         vim.lsp.buf.format()
--       end,
--     })
--   end
-- end

-- [lsp-new](https://neovim.io/doc/user/lsp/#lsp-new-config)
-- [lazyvim keymaps](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/keymaps.lua)
-- [lazyvim init](https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/plugins/lsp/init.lua)
local servers_dir = "lsp"
local servers = { "bashls", "lua_ls" }

return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      { "mason-org/mason.nvim",           opts = {} },
      { "mason-org/mason-lspconfig.nvim", config = function() end },
      -- { "WhoIsSethDaniel/mason-tool-installer.nvim" },
    },
    config = function()
      --- [lsp-attach](https://neovim.io/doc/user/lsp/#lsp-attach)
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("session-lsp-attach", { clear = true }),
        callback = function(ev)
          local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))

          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          if client:supports_method("textDocument/implementation") then
            -- Create a keymap for vim.lsp.buf.implementation ...
          end

          -- Enable auto-completion. Note: Use CTRL-Y to select an item. |complete_CTRL-Y|

          if client:supports_method("textDocument/completion") then
            -- Optional: trigger autocompletion on EVERY keypress. May be slow!
            -- local chars = {}; for i = 32, 126 do table.insert(chars, string.char(i)) end
            -- client.server_capabilities.completionProvider.triggerCharacters = chars
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
          end

          -- Auto-format ("lint") on save.
          -- Usually not needed if server supports "textDocument/willSaveWaitUntil".
          if
              not client:supports_method("textDocument/willSaveWaitUntil")
              and client:supports_method("textDocument/formatting")
          then
            vim.api.nvim_create_autocmd("BufWritePre", {
              group = vim.api.nvim_create_augroup("my.lsp", { clear = false }),
              buffer = ev.buf,
              callback = function()
                vim.lsp.buf.format({ bufnr = ev.buf, id = client.id, timeout_ms = 1000 })
              end,
            })
          end
        end,
      })

      local mason = require("mason")
      local mason_lsp = require("mason-lspconfig")

      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("blink.cmp").get_lsp_capabilities(capabilities)

      vim.notify("[nvim-lspconfig] trying to install. . .", vim.log.levels.INFO)

      mason_lsp.setup({
        ensure_installed = servers,
      })

      for _, server in ipairs(servers) do
        local server_dir = servers_dir .. "." .. server
        local conf_ok, conf = pcall(require, server_dir)
        vim.lsp.config(server, {
          capabilities = capabilities,
          on_attach = on_attach,
          settings = conf_ok and conf.settings or nil,
          filetypes = conf_ok and conf.filetypes or nil,
        })
      end

      -- Diagnostic Config
      -- See :help vim.diagnostic.Opts
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
        underline = { severity = vim.diagnostic.severity.ERROR },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
          },
        },
        virtual_text = {
          source = "if_many",
          spacing = 2,
          format = function(diagnostic)
            local diagnostic_message = {
              [vim.diagnostic.severity.ERROR] = diagnostic.message,
              [vim.diagnostic.severity.WARN] = diagnostic.message,
              [vim.diagnostic.severity.INFO] = diagnostic.message,
              [vim.diagnostic.severity.HINT] = diagnostic.message,
            }
            return diagnostic_message[diagnostic.severity]
          end,
        },
      })
    end,
  },
}
