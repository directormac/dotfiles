return {
  {
    'todo-comments.nvim',
    auto_enable = true,
    event = 'DeferredUIEnter',
    keys = {
      {
        ']t',
        function() require('todo-comments').jump_next() end,
        desc = 'Next Todo Comment',
      },
      {
        '[t',
        function() require('todo-comments').jump_prev() end,
        desc = 'Previous Todo Comment',
      },
      {
        '<leader>st',
        function()
          if package.loaded['snacks'] and Snacks.picker and Snacks.picker.todo_comments then
            Snacks.picker.todo_comments()
          else
            vim.cmd('TodoQuickFix')
          end
        end,
        desc = 'Todo',
      },
    },
    after = function() require('todo-comments').setup({}) end,
  },
}
