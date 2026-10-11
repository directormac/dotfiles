local M = {}

M.opts = {}

function M.keys()
  Snacks.toggle.option('spell', { name = 'Spelling' }):map('<leader>us')
  Snacks.toggle.option('wrap', { name = 'Wrap' }):map('<leader>uw')
  Snacks.toggle.option('relativenumber', { name = 'Relative Number' }):map('<leader>uL')
  Snacks.toggle.diagnostics():map('<leader>ud')
  Snacks.toggle.line_number():map('<leader>ul')
  Snacks.toggle
    .option('conceallevel', { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2 })
    :map('<leader>uc')
  Snacks.toggle.treesitter():map('<leader>uT')
  Snacks.toggle.option('background', { off = 'light', on = 'dark', name = 'Dark Background' }):map('<leader>ub')
  Snacks.toggle.inlay_hints():map('<leader>uh')
  Snacks.toggle.dim():map('<leader>uD')

  Snacks.toggle.profiler():map('<leader>dpp')
  Snacks.toggle.profiler_highlights():map('<leader>dph')

  Snacks.toggle.zoom():map('<leader>wm'):map('<leader>uZ'):map('<leader>Z')
  Snacks.toggle.zen():map('<leader>uz'):map('<leader>z')
end

return M
