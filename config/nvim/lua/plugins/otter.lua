return {
  {
    'otter.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    opts = {
      lsp = {
        diagnostic_update_events = { 'BufWritePost', 'InsertLeave' },
      },
      buffers = {
        set_filetype = true,
        write_to_disk = false,
      },
      handle_leading_whitespace = true,
      extensions = {
        toml = 'toml',
        kdl = 'kdl',
        -- tmux configuration embedded in Nix files (`# tmux` injections)
        tmux = 'tmux',
      },
      verbose = {
        no_code_found = false,
      },
    },
    -- after = function()
    --   -- otter creates a hidden buffer per embedded language and lets the
    --   -- matching language server attach to it. That gives completion, hover
    --   -- and diagnostics for the code that is embedded in a document, e.g. the
    --   -- shell script of `envrc.nix` (bash-language-server) or the tmux
    --   -- configuration of the tmux aspect (tmux-language-server).
    --   local group = vim.api.nvim_create_augroup('OtterActivate', { clear = true })
    --
    --   local function activate()
    --     local buf = vim.api.nvim_get_current_buf()
    --     local filetype = vim.bo[buf].filetype
    --     if filetype ~= 'nix' and filetype ~= 'markdown' then return end
    --     -- only for real files: scratch buffers (e.g. the ones that
    --     -- render-markdown uses to render embedded markdown) must not spawn
    --     -- otter buffers and language servers.
    --     if vim.bo[buf].buftype ~= '' then return end
    --     -- otter needs a treesitter parser with an injections query; both the
    --     -- nix and the markdown queries provide one.
    --     pcall(require('otter').activate)
    --   end
    --
    --   vim.api.nvim_create_autocmd('FileType', {
    --     group = group,
    --     callback = activate,
    --   })
    --
    --   -- The plugin is loaded on BufReadPost, so the FileType event of the
    --   -- first buffer has already been fired.
    --   activate()
    -- end,
  },
}
