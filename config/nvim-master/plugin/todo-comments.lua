require('lazyload').on_vim_enter(function()
  vim.pack.add({ 'https://github.com/folke/todo-comments.nvim' })

  require('todo-comments').setup({})

  -- { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
  --   ( "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" ),
  --   { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
  --   { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
  --   { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Todo" },
  --   { "<leader>sT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>", desc = "Todo/Fix/Fixme" },
end)
