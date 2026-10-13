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
      },
      verbose = {
        no_code_found = false,
      },
    },
  },
}
