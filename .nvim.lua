vim.lsp.config("nixd", {
	cmd = { "nixd" },
	filetypes = { "nix" },
	root_dir = vim.uv.cwd(),
	settings = {
		nixd = {
			nixpkgs = {
				expr = 'import (builtins.getFlake "' .. vim.uv.cwd() .. '").inputs.nixpkgs { }',
			},
			formatting = {
				command = { "treefmt" },
			},
		},
	},
})

vim.lsp.enable("nixd")
