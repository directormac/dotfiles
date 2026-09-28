return {

  {
    'akinsho/bufferline.nvim',
    keys = {
        -- stylua: ignore
        { "<A-1>", function() require("bufferline").go_to(1, true) end, desc = "Go to first buffer", },
        -- stylua: ignore
        { "<A-2>", function() require("bufferline").go_to(2, true) end, desc = "Go to second buffer", },
        -- stylua: ignore
        { "<A-3>", function() require("bufferline").go_to(3, true) end, desc = "Go to third buffer", },
        -- stylua: ignore
        { "<A-4>", function() require("bufferline").go_to(4, true) end, desc = "Go to fourth buffer", },
        -- stylua: ignore
        { "<A-5>", function() require("bufferline").go_to(5, true) end, desc = "Go to fifth buffer", },
        -- stylua: ignore
        { "<A-6>", function() require("bufferline").go_to(6, true) end, desc = "Go to sixth buffer", },
    },
    opts = function(_, opts)
      opts.highlights = {
        indicator_selected = {
          fg = '#cba6f7',
        },
      }
      opts.options = {
        always_show_bufferline = true,
        separator_style = 'thin',
        show_buffer_close_icons = false,
        show_duplicate_prefix = true,
        persist_buffer_sort = true,
        offsets = {
          {
            filetype = 'oil',
            text = 'file explorer',
            highlight = 'Directory',
            text_align = 'left',
          },
        },
      }
    end,
  },
}
