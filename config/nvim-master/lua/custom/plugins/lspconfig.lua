-- [[ LSP Configuration ]]
-- Brief aside: **What is LSP?**
--
-- LSP is an initialism you've probably heard, but might not understand what it is.
--
-- LSP stands for Language Server Protocol. It's a protocol that helps editors
-- and language tooling communicate in a standardized fashion.
--
-- In general, you have a "server" which is some tool built to understand a particular
-- language (such as `gopls`, `lua_ls`, `rust_analyzer`, etc.). These Language Servers
-- (sometimes called LSP servers, but that's kind of like ATM Machine) are standalone
-- processes that communicate with some "client" - in this case, Neovim!
--
-- LSP provides Neovim with features like:
--  - Go to definition
--  - Find references
--  - Autocompletion
--  - Symbol Search
--  - and more!
--
-- Thus, Language Servers are external tools that must be installed separately from
-- Neovim. This is where `mason` and related plugins come into play.
--
-- If you're wondering about lsp vs treesitter, you can check out the wonderfully
-- and elegantly composed help section, `:help lsp-vs-treesitter`

-- Useful status updates for LSP.
vim.pack.add({ 'https://github.com/j-hui/fidget.nvim' })
require('fidget').setup({})

--  This function gets run when an LSP attaches to a particular buffer.
--    That is to say, every time a new file is opened that is associated with
--    an lsp (for example, opening `main.rs` is associated with `rust_analyzer`) this
--    function will be executed to configure the current buffer

local completion = vim.g.completion_mode or 'blink' -- or 'native'
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('auto-lsp-attach', { clear = true }),
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    local buf = args.buf

    if client then
      -- Built-in completion
      if completion == 'native' and client:supports_method('textDocument/completion') then
        vim.lsp.completion.enable(true, client.id, args.buf, { autotrigger = true })
      end

      if client:supports_method('textDocument/inlayHint') then
        vim.lsp.inlay_hint.enable(false, { bufnr = buf })
        vim.notify('Inlay hints supported, press <Leader>+uh to toggle.')
      end

      -- -- On-type formatting, but not from tsserver: it re-indents lines as you
      -- -- type `;`, `}` or newline using its own style, not the project's.
      if not client:supports_method('textDocument/onTypeFormatting') then
        vim.lsp.on_type_formatting.enable(true, { client_id = client.id })

        vim.keymap.set(
          { 'n', 'v' },
          '<leader>cF',
          function() require('conform').format({ async = true, bufnr = buf, lsp_format = 'first' }) end,
          { desc = 'Format Injected Language.' }
        )
      end

      if client:supports_method('textDocument/documentColor') then
        vim.lsp.document_color.enable(true, { bufnr = buf }, {
          style = 'virtual',
        })
      end

      local default_keymaps = {
        { keys = '<leader>ca', func = vim.lsp.buf.code_action, desc = 'Code Actions' },
        { keys = '<leader>cr', func = vim.lsp.buf.rename, desc = 'Code Rename' },
        { keys = '<leader>k', func = vim.lsp.buf.hover, desc = 'Hover Documentation', has = 'hoverProvider' },
        { keys = 'K', func = vim.lsp.buf.hover, desc = 'Hover (alt)', has = 'hoverProvider' },
      }

      for _, km in ipairs(default_keymaps) do
        -- Only bind if there's no `has` requirement, or the server supports it
        if not km.has or client.server_capabilities[km.has] then
          vim.keymap.set(
            km.mode or 'n',
            km.keys,
            km.func,
            { buffer = buf, desc = 'LSP: ' .. km.desc, nowait = km.nowait }
          )
        end
      end
    end
  end,
})

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--  See `:help lsp-config` for information about keys and how to configure
---@type table<string, vim.lsp.Config>
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  --
  -- Some languages (like typescript) have entire language plugins that can be useful:
  --    https://github.com/pmizio/typescript-tools.nvim
  --
  -- But for many setups, the LSP (`ts_ls`) will work just fine
  -- ts_ls = {},

  taplo = {},

  stylua = {}, -- Used to format Lua code

  -- Special Lua Config, as recommended by neovim help docs
  lua_ls = {
    on_init = function(client)
      client.server_capabilities.documentFormattingProvider = false -- Disable formatting (formatting is done by stylua)

      if client.workspace_folders then
        local path = client.workspace_folders[1].name
        if
          path ~= vim.fn.stdpath('config')
          and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
        then
          return
        end
      end

      local current_settings = client.config.settings --[[@as lspconfig.settings.lua_ls]]
      client.config.settings.Lua = vim.tbl_deep_extend('force', current_settings.Lua, {
        -- Define runtime properties. Use 'LuaJIT', as it is built into Neovim.
        -- runtime = { version = 'LuaJIT', path = vim.split(package.path, ';') },
        runtime = {
          version = 'LuaJIT',
          path = { 'lua/?/init.lua' },
        },
        workspace = {
          -- Don't analyze code from submodules
          ignoreSubmodules = true,
          checkThirdParty = false,
          -- library = { vim.env.VIMRUNTIME },
          -- -- NOTE: this is a lot slower and will cause issues when working on your own configuration.
          -- --  See https://github.com/neovim/nvim-lspconfig/issues/3189
          library = vim.api.nvim_get_runtime_file('', true),
        },
      })
    end,
    ---@type lspconfig.settings.lua_ls
    settings = {
      Lua = {
        format = { enable = false }, -- Disable formatting (formatting is done by stylua)
      },
    },
  },
}

-- vim.pack.add { 'https://github.com/williamboman/mason.nvim' } -- 'mason-org/mason.nvim' redirects to williamboman
-- vim.pack.add { 'https://github.com/williamboman/mason-lspconfig.nvim' }
vim.pack.add({ 'https://github.com/mason-org/mason.nvim' }) -- 'mason-org/mason.nvim' redirects to williamboman
vim.pack.add({ 'https://github.com/mason-org/mason-lspconfig.nvim' })
vim.pack.add({ 'https://github.com/WhoIsSethDaniel/mason-tool-installer.nvim' })
vim.pack.add({ 'https://github.com/neovim/nvim-lspconfig' })

-- Automatically install LSPs and related tools to stdpath for Neovim
require('mason').setup({})

-- Translates between nvim-lspconfig server names and mason.nvim package names (e.g. lua_ls <-> lua-language-server)
require('mason-lspconfig').setup({
  automatic_enable = false, -- Change this to true if you want to automatically enable servers that are installed manually (e.g. via :Mason / :MasonInstall)
})

-- Ensure the servers and tools above are installed
--
-- To check the current status of installed tools and/or manually install
-- other tools, you can run
--    :Mason
--
-- You can press `g?` for help in this menu.
local ensure_installed = vim.tbl_keys(servers or {})
vim.list_extend(ensure_installed, {
  -- You can add other tools here that you want Mason to install
})

require('mason-tool-installer').setup({ ensure_installed = ensure_installed })

for name, server in pairs(servers) do
  vim.lsp.config(name, server)
  vim.lsp.enable(name)
end
