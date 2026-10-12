return {
  {
    'vyfor/cord.nvim',
    ---@type CordConfig
    opts = {

      editor = {
        client = '1172814933776404491',
        icon = 'https://githubusercontent.com',
      },

      -- display = {
      --   theme = "catppuccin",
      -- },

      idle = {
        details = function(opts) return 'Taking a break from ' .. opts.workspace end,
        state = 'Be right back',
        tooltip = '😴 ? ☕',
      },

      text = {
        editing = function(opts) return 'Editing ' .. opts.filename end,
        workspace = function(opts) return 'Project: ' .. opts.workspace end,
        terminal = function(opts) return 'In a terminal (' .. opts.name .. ')' end,
      },

      advance = {
        discord = {
          reconnect = {
            enabled = true,
          },
        },
      },
    },
  },
}
