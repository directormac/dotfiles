local M = {}
local is_nixos = vim.fn.system("uname -r") == 0

if not is_nixos then
	M = {
		{ "williamboman/mason.nvim", opts = {} },
	}
end

return M
