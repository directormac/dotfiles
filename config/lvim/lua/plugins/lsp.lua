return {
  {
    'neovim/nvim-lspconfig',
    ---@class PluginLspOpts
    opts = function(_, opts)
      vim.lsp.config('nixd', {
        cmd = { 'nixd' },
        settings = {
          nixd = {
            nixpkgs = {
              expr = 'import <nixpkgs> { }',
            },
            formatting = {
              command = { 'nixfmt' },
            },
            -- options = {
            --   nixos = {
            --     expr = '(builtins.getFlake (toString ./.)).nixosConfigurations.<hostname>.options',
            --   },
            --   home_manager = {
            --     expr = '(builtins.getFlake (toString ./.)).homeConfigurations."<username>@<hostname>".options',
            --   },
            -- },
          },
        },
      })
      vim.lsp.enable('nixd')
      return opts
    end,
  },
}
