---@diagnostic disable: lowercase-global
local wezterm = require("wezterm")
local mux = wezterm.mux
local act = wezterm.action
local wsl_domains = wezterm.default_wsl_domains()
local config = {}
config.ssh_domains = wezterm.default_ssh_domains()
if wezterm.target_triple == "x86_64-pc-windows-msvc" then
	-- We are running on Windows; maybe we emit different
	-- key assignments here?
	config.ssh_domains = {
		{
			name = "ArchX",
			remote_address = "192.168.110.182",
			username = "artifex",
		},
		{
			name = "xUbuntu",
			remote_address = "192.168.110.174",
			username = "artifex",
		},
	}
	config.wsl_domains = wsl_domains
	for _, domain in ipairs(wsl_domains) do
		domain.default_cwd = "~"
	end
	config.default_prog = { "C:\\Program Files\\PowerShell\\7\\pwsh.exe" }
end

if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
	--   -- We are running on Windows; maybe we emit different
	--   -- key assignments here?
end

--REMOTE CONFIGURATIONS

for _, domain in ipairs(config.ssh_domains) do
	domain.assume_shell = "Posix"
	-- domain.default_cwd = "~"
end

wezterm.on("mux-startup", function()
	local tab, pane, window = mux.spawn_window({})
	-- pane:split { direction = 'Bottom' }
end)

wezterm.on("gui-startup", function()
	local tab, pane, window = mux.spawn_window({})
	-- window:gui_window():maximize()
	-- window:spawn_tab {}
	-- pane:split { direction = 'Bottom' }
	-- window.gui_window():toggle_fullscreen()
end)

wezterm.on("update-right-status", function(window, pane)
	local cells = {}
	local workspace = window:active_workspace()
	local cwd_uri = pane:get_current_working_dir()
	-- table.insert(cells, "")
	local name = window:active_key_table()
	if name then
		name = "MODE - " .. name
	end
	name = string.format("%s", name or "")
	table.insert(cells, name)
	if workspace then
		if workspace == "default" then
			-- table.insert(cells, " ")
			table.insert(cells, "")
		else
			table.insert(cells, workspace)
		end
	end

	if cwd_uri then
		cwd_uri = cwd_uri:sub(8)
		local slash = cwd_uri:find("/")
		local cwd = ""
		local hostname = ""
		if slash then
			hostname = cwd_uri:sub(1, slash - 1)
			-- Remove the domain name portion of the hostname
			local dot = hostname:find("[.]")
			if dot then
				hostname = hostname:sub(1, dot - 1)
			end
			-- and extract the cwd from the uri
			cwd = cwd_uri:sub(slash)

			table.insert(cells, cwd)
			table.insert(cells, hostname)
		end
	end
	-- I like my date/time in this style: "Wed Mar 3 08:14"
	local date = wezterm.strftime("%a %b %-d %H:%M")
	table.insert(cells, date)

	-- The filled in variant of the < symbol
	local ARROW = utf8.char(0xe0b2)
	local FIRE = utf8.char(0xe0c2)
	local SLASH = utf8.char(0xe0ba)
	local colors = {
		"#11111b",
		"#11111b",
		"#1e1e2e",
		"#313244",
		"#45475a",
		"#6c7086",
	}

	local text_colors = {
		"#f5c2e7",
		"#cba6f7",
		"#f38ba8",
		"#eba0ac",
		"#a6e3a1",
		"#fab387",
	}

	-- The elements to be formatted
	local elements = {}
	-- How many cells have been formatted
	local num_cells = 0

	-- Translate a cell into elements
	function push(text, is_last)
		local cell_no = num_cells + 1
		table.insert(elements, { Foreground = { Color = text_colors[cell_no] } })
		table.insert(elements, { Background = { Color = colors[cell_no] } })
		table.insert(elements, { Text = " " .. text .. " " })
		if not is_last then
			table.insert(elements, { Foreground = { Color = colors[cell_no + 1] } })
			table.insert(elements, { Text = ARROW })
		end
		num_cells = num_cells + 1
	end

	while #cells > 0 do
		local cell = table.remove(cells, 1)
		push(cell, #cells == 0)
	end

	window:set_right_status(wezterm.format(elements))
end)

function get_process(tab)
	local process_icons = {
		["node"] = { { Foreground = { Color = "#a6e3a1" } }, { Text = "" } },
		["yarn"] = { { Foreground = { Color = "#8caaee" } }, { Text = "" } },
		["nvim"] = { { Foreground = { Color = "#a6e3a1" } }, { Text = " " } },
		["v"] = { { Foreground = { Color = "#94e2d5" } }, { Text = " " } },
		["vi"] = { { Foreground = { Color = "#f38ba8" } }, { Text = " " } },
		["cargo"] = { { Foreground = { Color = "#f38ba8" } }, { Text = " " } },
		["pnpm"] = { { Foreground = { Color = "#a6e3a1" } }, { Text = " " } },
		["hx"] = { { Foreground = { Color = "#a6e3a1" } }, { Text = " " } },
		["btm"] = { { Text = " " } },
		["zsh"] = { { Foreground = { Color = "#f5e0dc" } }, { Text = " " } },
		["docker"] = { { Foreground = { Color = "#8caaee" } }, { Text = " " } },
		["pwsh.exe"] = { { Foreground = { Color = "#74c7ec" } }, { Text = " " } },
		["cmd.exe"] = { { Foreground = { Color = "#74c7ec" } }, { Text = " " } },
		["~"] = { { Foreground = { Color = "#74c7ec" } }, { Text = " " } },
	}
	local process_name = string.gsub(tab.active_pane.title, "(.*[/\\])(.*)", "%2")
	if not process_name then
		process_name = "zsh"
	end
	return wezterm.format(
		process_icons[process_name]
			or { { Foreground = { Color = "#f5c2e7" } }, { Text = string.format("%s", process_name) } }
	)
end

function get_current_working_folder_name(tab)
	local cwd_uri = tab.active_pane.current_working_dir
	cwd_uri = cwd_uri:sub(8)
	local slash = cwd_uri:find("/")
	local cwd = cwd_uri:sub(slash)
	local HOME_DIR = os.getenv("HOME")
	if cwd == HOME_DIR then
		return "   ~"
	elseif not cwd then
		return " "
	end
	return string.format("  %s ", string.match(cwd, "[^/]+$"))
end

wezterm.on("format-tab-title", function(tab)
	local SOLID_LEFT_ARROW = utf8.char(0xe0b0)
	return wezterm.format({
		-- { Attribute = { Intensity = "Half" } },
		-- { Foreground = { Color = "#cba6f7" } },
		-- { Text = string.format(" %s ", tab.tab_index + 1) },
		-- "ResetAttributes",
		{ Text = " " },
		{ Text = get_process(tab) },
		-- { Foreground = { Color = "#cdd6f4" } },
		{ Text = get_current_working_folder_name(tab) },
		{ Foreground = { Color = "#1e1e2e" } },
		-- { Text = "    ▕" },
		{ Text = "▕" },
	})
end)
-- local gpus = wezterm.gui.enumerate_gpus()
-- config.webgpu_preferred_adapter = gpus[1]
-- config.front_end = 'WebGpu'
config.status_update_interval = 1
config.color_scheme = "Catppuccin Mocha"
config.colors = {
	tab_bar = {
		-- font_size = 20,
		active_tab = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
			intensity = "Bold",
		},
		-- inactive_tab = {
		--   bg_color = '#181825',
		--   fg_color = '#cdd6f4',
		--   intensity = 'Bold',
		-- },

		-- new_tab = {
		--   bg_color = '#181825',
		--   fg_color = '#cdd6f4',
		--   intensity = 'Bold',
		-- },
		-- new_tab_hover = {
		--   bg_color = '#181825',
		--   fg_color = '#cdd6f4',
		--   intensity = 'Bold',
		-- }
	},
}
config.initial_cols = 120
config.initial_rows = 35
config.font = wezterm.font({
	family = "FiraCode Nerd Font",
	weight = "Regular",
	stretch = "Normal",
	style = "Normal",
	harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
	-- scale = 1.0
})
-- config.window_grame = {
--   font_size = 20
-- }
config.font_size = 14
config.window_decorations = "RESIZE"
config.window_background_opacity = 0.73
-- config.window_background_image = 'C://tools/bg.jpg'
-- config.tab_bar_at_bottom = true
config.scrollback_lines = 50000
config.adjust_window_size_when_changing_font_size = false
config.audible_bell = "Disabled"
config.exit_behavior = "Close"
config.window_close_confirmation = "NeverPrompt"
config.hide_mouse_cursor_when_typing = true
config.hide_tab_bar_if_only_one_tab = true
config.use_fancy_tab_bar = false
config.inactive_pane_hsb = {
	saturation = 1.0,
	brightness = wezterm.GLOBAL.is_dark and 0.90 or 0.95,
}
config.tab_max_width = 50
-- config.window_padding = {
--   left = 2,
--   right = 2,
--   top = 1,
--   bottom = 1,
-- }
--KEY BINDINGS
config.disable_default_key_bindings = true
-- LEADER Key is CTRL+a will be addressed below as <Leader>
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
	{ key = "p", mods = "LEADER", action = act.ActivateCommandPalette },
	{
		key = "s",
		mods = "LEADER",
		action = act.ShowLauncherArgs({ flags = "FUZZY|WORKSPACES|DOMAINS" }),
	},
	{ key = "n", mods = "LEADER", action = act.SwitchToWorkspace },
	{ key = ">", mods = "LEADER|SHIFT", action = act.SwitchWorkspaceRelative(1) },
	{ key = "<", mods = "LEADER|SHIFT", action = act.SwitchWorkspaceRelative(-1) },
	{
		key = "-",
		mods = "LEADER",
		action = act({ SplitVertical = {
			domain = "CurrentPaneDomain",
		} }),
	},
	{
		key = "\\",
		mods = "LEADER",
		action = act({ SplitHorizontal = {
			domain = "CurrentPaneDomain",
		} }),
	},
	{ key = "z", mods = "LEADER", action = "TogglePaneZoomState" },
	{ key = "c", mods = "LEADER", action = act({ SpawnTab = "CurrentPaneDomain" }) },
	{ key = "x", mods = "LEADER", action = act.CloseCurrentPane({ confirm = false }) },
	{ key = "w", mods = "LEADER", action = act.CloseCurrentTab({ confirm = false }) },
	{ key = "-", mods = "LEADER|CTRL", action = act.DecreaseFontSize },
	{ key = "=", mods = "LEADER|CTRL", action = act.IncreaseFontSize },
	{ key = "0", mods = "LEADER", action = act.ResetFontAndWindowSize },
	{ key = "r", mods = "LEADER", action = act.ActivateKeyTable({ name = "resize_pane", one_shot = false }) },
	{
		key = "f",
		mods = "LEADER",
		action = act.ActivateKeyTable({ name = "super", one_shot = false }),
	},
	{ key = "q", mods = "LEADER", action = act.PaneSelect },
	{ key = "h", mods = "LEADER", action = act({ ActivatePaneDirection = "Left" }) },
	{ key = "j", mods = "LEADER", action = act({ ActivatePaneDirection = "Down" }) },
	{ key = "k", mods = "LEADER", action = act({ ActivatePaneDirection = "Up" }) },
	{ key = "l", mods = "LEADER", action = act({ ActivatePaneDirection = "Right" }) },
	{ key = "H", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Left", 5 } }) },
	{ key = "J", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Down", 5 } }) },
	{ key = "K", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Up", 5 } }) },
	{ key = "L", mods = "LEADER|SHIFT", action = act({ AdjustPaneSize = { "Right", 5 } }) },
	{ key = "Tab", mods = "CTRL", action = act({ ActivateTabRelative = 1 }) },
	{ key = "1", mods = "ALT", action = act({ ActivateTab = 0 }) },
	{ key = "2", mods = "ALT", action = act({ ActivateTab = 1 }) },
	{ key = "3", mods = "ALT", action = act({ ActivateTab = 2 }) },
	{ key = "4", mods = "ALT", action = act({ ActivateTab = 3 }) },
	{ key = "5", mods = "ALT", action = act({ ActivateTab = 4 }) },
	{ key = "6", mods = "ALT", action = act({ ActivateTab = 5 }) },
	{ key = "7", mods = "ALT", action = act({ ActivateTab = 6 }) },
	{ key = "8", mods = "ALT", action = act({ ActivateTab = 7 }) },
	{ key = "9", mods = "ALT", action = act({ ActivateTab = 8 }) },
	{ key = "c", mods = "CTRL|SHIFT", action = act({ CopyTo = "ClipboardAndPrimarySelection" }) },
	{ key = "v", mods = "CTRL|SHIFT", action = act({ PasteFrom = "Clipboard" }) },
	{ key = "F11", action = act.ToggleFullScreen },
}

config.key_tables = {
	resize_pane = {
		{ key = "LeftArrow", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "h", action = act.AdjustPaneSize({ "Left", 1 }) },
		{ key = "RightArrow", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "l", action = act.AdjustPaneSize({ "Right", 1 }) },
		{ key = "UpArrow", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "k", action = act.AdjustPaneSize({ "Up", 1 }) },
		{ key = "DownArrow", action = act.AdjustPaneSize({ "Down", 1 }) },
		{ key = "j", action = act.AdjustPaneSize({ "Down", 1 }) },
		-- Cancel the mode by pressing escape
		{ key = "Escape", action = "PopKeyTable" },
	},
	super = {
		{ key = "`", mods = "CTRL", action = "PopKeyTable" },
		{ key = "Space", mods = "NONE", action = act.Search({ CaseInSensitiveString = "" }) },
		{ key = "n", mods = "CTRL", action = act.CopyMode("NextMatch") },
		{ key = "p", mods = "CTRL", action = act.CopyMode("PriorMatch") },
		{ key = "r", mods = "CTRL", action = act.CopyMode("CycleMatchType") },
		{ key = "PageUp", mods = "NONE", action = act.CopyMode("PriorMatchPage") },
		{ key = "PageDown", mods = "NONE", action = act.CopyMode("NextMatchPage") },
		{ key = "s", mods = "CTRL", action = act.CopyMode("ClearPattern") },
		{ key = "Escape", mods = "NONE", action = act.Multiple({ act.CopyMode("Close"), "PopKeyTable" }) },
		{ key = "RightArrow", mods = "NONE", action = act.CopyMode("MoveRight") },
		{ key = "LeftArrow", mods = "NONE", action = act.CopyMode("MoveLeft") },
		{ key = "UpArrow", mods = "NONE", action = act.CopyMode("MoveUp") },
		{ key = "DownArrow", mods = "NONE", action = act.CopyMode("MoveDown") },
		{ key = "K", mods = "CTRL", action = act.ScrollByPage(-0.5) },
		{ key = "J", mods = "CTRL", action = act.ScrollByPage(1) },
		{ key = "k", mods = "CTRL", action = act.ScrollByLine(-1) },
		{ key = "j", mods = "CTRL", action = act.ScrollByLine(1) },
		{ key = "c", mods = "CTRL|SHIFT", action = act({ CopyTo = "ClipboardAndPrimarySelection" }) },
	},
}
for i = 1, 8 do
	-- CTRL+ALT + number to move to that position
	table.insert(config.keys, {
		key = tostring(i),
		mods = "CTRL|ALT",
		action = act.MoveTab(i - 1),
	})
end

config.mouse_bindings = {
	-- Scrolling up while holding CTRL increases the font size
	{
		event = { Down = { streak = 1, button = { WheelUp = 1 } } },
		mods = "CTRL",
		action = act.IncreaseFontSize,
	},

	-- Scrolling down while holding CTRL decreases the font size
	{
		event = { Down = { streak = 1, button = { WheelDown = 1 } } },
		mods = "CTRL",
		action = act.DecreaseFontSize,
	},

	-- {
	--   event = { Drag = { streak = 1, button = 'Left' } },
	--   mods = 'CTRL',
	--   action = act.StartWindowDrag,
	-- },
}

return config
-- rosewater = "#f5e0dc",
-- 		flamingo = "#f2cdcd",
-- 		pink = "#f5c2e7",
-- 		mauve = "#cba6f7",
-- 		red = "#f38ba8",
-- 		maroon = "#eba0ac",
-- 		peach = "#fab387",
-- 		yellow = "#f9e2af",
-- 		green = "#a6e3a1",
-- 		teal = "#94e2d5",
-- 		sky = "#89dceb",
-- 		sapphire = "#74c7ec",
-- 		blue = "#89b4fa",
-- 		lavender = "#b4befe",
-- 		text = "#cdd6f4",
-- 		subtext1 = "#bac2de",
-- 		subtext0 = "#a6adc8",
-- 		overlay2 = "#9399b2",
-- 		overlay1 = "#7f849c",
-- 		overlay0 = "#6c7086",
-- 		surface2 = "#585b70",
-- 		surface1 = "#45475a",
-- 		surface0 = "#313244",
-- 		base = "#1e1e2e",
-- 		mantle = "#181825",
-- 		crust = "#11111b",
