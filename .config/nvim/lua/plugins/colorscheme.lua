return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    -- commit = "f19cab18ec4dc86d415512c7a572863b2adbcc18",
    opts = {
      transparent = true,
      transparent_background = true,
      float = {
        transparent = true,
        solid = true,
      },
      falvour = "mocha",
      color_overrides = {
        all = {
          base = "#11111B",
          mantle = "#11111B",
        },
      },
      custom_highlights = function(colors)
        return {
          -- Comment = { fg = colors.flamingo },
          RenderMarkdownCode = { bg = colors.mantle },
        }
      end,
      -- highlight_overrides = {
      --   all = function(colors)
      --     return {}
      --   end,
      -- },
    },

    -- show_end_of_buffer = false,
    term_colors = true,
    -- specs = {
    --   {
    --     "akinsho/bufferline.nvim",
    --     optional = true,
    --     opts = function(_, opts)
    --       if (vim.g.colors_name or ""):find("catppuccin") then
    --         opts.highlights = require("catppuccin.special.bufferline").get_theme()
    --       end
    --     end,
    --   },
    -- },
  },
  {
    "folke/tokyonight.nvim",
    opts = {
      transparent = true,
      terminal_colors = true,
      style = "night",
      light_style = "night",
      styles = {
        sidebars = "transparent",
        floats = "transparent",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
      -- colorscheme = "tokyonight",
    },
  },
}
