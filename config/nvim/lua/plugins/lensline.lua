return {
  'lensline.nvim',
  event = 'LspAttach',
  after = function() require('lensline').setup({}) end,
}
