-- Read more here https://swarsel.github.io/pedantix/configuration.html
-- or type `:h exrc`

require("conform").setup({
	formatters_by_ft = {
		nix = { "treefmt" },
	},
	formatters = {
		treefmt = {
			command = "treefmt",
			-- Tell conform that the project root is flake.nix / .git, NOT treefmt.toml:
			cwd = require("conform.util").root_file({ "flake.nix", ".git" }),
			require_cwd = true,
		},
	},
})

---@type vim.lsp.Config
vim.lsp.config("nil_ls", {
	---@type lspconfig.settings.nil_ls
	settings = {
		formatting = {
			command = { "treefmt" },
		},
	},
})

---@type vim.lsp.Config
vim.lsp.config("nixd", {
	---@type lspconfig.settings.nixd
	settings = {
		nixd = {
			nixpkgs = {
				expr = "import <nixpkgs> { }",
			},
			formatting = {
				command = { "treefmt" },
			},
			options = {
				nixos = {
					expr = '(let pkgs = import "${inputs.nixpkgs}" { }; in (pkgs.lib.evalModules { modules =  (import "${inputs.nixpkgs}/nixos/modules/module-list.nix") ++ [ ({...}: { nixpkgs.hostPlatform = builtins.currentSystem;} ) ] ; })).options',
				},
				home_manager = {
					expr = '(let pkgs = import "${inputs.nixpkgs}" { }; lib = import "${inputs.home-manager}/modules/lib/stdlib-extended.nix" pkgs.lib; in (lib.evalModules { modules =  (import "${inputs.home-manager}/modules/modules.nix") { inherit lib pkgs; check = false; }; })).options',
				},
			},
		},
	},
})

vim.lsp.enable({
	"lua_ls",
	"nixd",
	"taplo",
	"nil_ls",
})
