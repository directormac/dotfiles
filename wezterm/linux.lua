local term = require("wezterm")

local M = {}

function M.options(config)
	local ssh_domains = term.default_ssh_domains() -- Load SSH Domains from ~/.ssh/config

	local extra_ssh = {
		-- {
		-- 	name = "ArchX",
		-- 	remote_address = "192.168.110.182",
		-- 	username = "artifex",
		-- },
	}

	for _, domain in ipairs(extra_ssh) do
		table.insert(ssh_domains, domain)
	end

	term.unix_domains = {
		{
			name = "unix",
		},
		{
			name = "artifex",
		},
	}

	term.defailt_gui_startuo_args = { "connect", "unix" }

	-- config.ssh_domains = ssh_domains

	-- config.default_prog = { "bash" }
end

return M
