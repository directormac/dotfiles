return {
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
    },
    verbose = {
      no_code_found = false,
    },
  },
  after = function(plugin)
    local otter = require('otter')
    otter.setup(plugin.opts or {})
    --
    -- local group = vim.api.nvim_create_augroup('otter-autostart', { clear = true })
    -- vim.api.nvim_create_autocmd('FileType', {
    --   group = group,
    --   pattern = { 'nix', 'markdown' },
    --   callback = function(args)
    --     if vim.g.otter_enabled ~= false and not vim.b[args.buf].otter_disabled then
    --       otter.activate(nil, true, true)
    --     end
    --   end,
    -- })
  end,
}
