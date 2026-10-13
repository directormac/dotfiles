return {
  'catppuccin-nvim',
  colorscheme = 'catppuccin',

  ---@type CatppuccinOptions
  opts = {
    flavour = 'mocha',
    background = { light = 'latte', dark = 'mocha' },
    transparent_background = true,
    float = {
      transparent = true,
      solid = false,
    },
    term_colors = true,
    lsp_styles = {
      virtual_text = {
        errors = { 'italic' },
        hints = { 'italic' },
        warnings = { 'italic' },
        information = { 'italic' },
        ok = { 'italic' },
      },
      underlines = {
        errors = { 'underline' },
        hints = { 'underline' },
        warnings = { 'underline' },
        information = { 'underline' },
        ok = { 'underline' },
      },
      inlay_hints = {
        background = true,
      },
    },
    integrations = {
      blink_cmp = true,
      blink_pairs = true,
      bufferline = true,
      dap = true,
      dap_ui = true,
      flash = true,
      gitsigns = true,
      grug_far = true,
      harpoon = true,
      noice = true,
      nvim_surround = true,
      nvimtree = true,
      octo = true,
      render_markdown = true,
      snacks = true,
      treesitter = true,
      treesitter_context = true,
      which_key = true,
    },
  },
  after = function(plugin)
    require('catppuccin').setup(plugin.opts or {})

    -- Set Line Number Colors
    vim.api.nvim_create_autocmd({ 'ColorScheme', 'InsertEnter', 'InsertLeave', 'ModeChanged' }, {
      callback = function()
        vim.cmd('hi CursorLineNr guifg=#cba6f7 gui=bold')
        vim.cmd('hi SnacksIndenScope guifg=#89b4fa gui=bold')
      end,
    })
  end,
}
