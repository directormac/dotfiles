return {
  'snacks.nvim',
  opts = {
    ---@class snacks.image.Config
    image = {
      enabled = true,
      doc = {
        enabled = true,
        inline = true,
        float = true,
        max_width = 80,
        max_height = 40,
      },
      convert = {
        notify = false,
        ---@type snacks.image.args
        mermaid = function()
          local theme = vim.o.background == 'light' and 'neutral' or 'dark'
          return { '-i', '{src}', '-o', '{file}', '-b', 'transparent', '-t', theme, '-s', '{scale}' }
        end,
      },
    },
  },
}
