return {
  'snacks.nvim',
  keys = {
    { '<c-/>', function() Snacks.terminal() end, desc = 'Toggle Terminal' },
    { '<c-_>', function() Snacks.terminal() end, desc = 'which_key_ignore' },
  },
  opts = function()
    local function term_nav(dir)
      ---@param self snacks.terminal
      return function(self)
        return self:is_floating() and '<c-' .. dir .. '>' or vim.schedule(function() vim.cmd.wincmd(dir) end)
      end
    end

    return {
      terminal = {
        win = {
          keys = {
            nav_h = { '<C-h>', term_nav('h'), desc = 'Go to Left Window', expr = true, mode = 't' },
            nav_j = { '<C-j>', term_nav('j'), desc = 'Go to Lower Window', expr = true, mode = 't' },
            nav_k = { '<C-k>', term_nav('k'), desc = 'Go to Upper Window', expr = true, mode = 't' },
            nav_l = { '<C-l>', term_nav('l'), desc = 'Go to Right Window', expr = true, mode = 't' },
            hide_slash = { '<C-/>', 'hide', desc = 'Hide Terminal', mode = 't' },
            hide_underscore = { '<c-_>', 'hide', desc = 'which_key_ignore', mode = 't' },
          },
        },
      },
    }
  end,
}
