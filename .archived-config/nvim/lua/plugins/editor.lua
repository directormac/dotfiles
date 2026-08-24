return {
  {
    "folke/trouble.nvim",
    opts = {
      auto_preview = true,
      multitile = true,
      modes = {
        preview_float = {
          mode = "diagnostics",
          preview = {
            type = "float",
            relative = "editor",
            border = "rounded",
            title = "Preview",
            title_pos = "center",
            position = { 0, -2 },
            size = { width = 0.3, height = 0.3 },
            zindex = 200,
          },
        },
        preview = {
          type = "float",
          relative = "editor",
          border = "rounded",
          title = "Preview",
          title_pos = "center",
          position = { 0, -2 },
          size = { width = 0.3, height = 0.3 },
          zindex = 200,
        },
      },
      keys = {
        ["go"] = {
          action = function(_, ctx)
            if not ctx.item then
              return
            end
            local diag = ctx.item
            if diag and diag.reference and diag.reference.url then
              local url = diag.reference.url
              if url and url ~= "" then
                vim.ui.open(url)
                return
              end
            end

            vim.notify("No reference URL found for this diagnostic.", vim.log.levels.WARN)
          end,
          desc = "Open Diagnostic URL in Browser",
        },
      },
    },
  },
}
