local term = require("wezterm")

local M = {}

---- Appearance
-- config.front_end = "OpenGL"
-- Color pallete
M.colors = {
	rosewater = "#f5e0dc",
	flamingo = "#f2cdcd",
	pink = "#f5c2e7",
	mauve = "#cba6f7",
	red = "#f38ba8",
	maroon = "#eba0ac",
	peach = "#fab387",
	yellow = "#f9e2af",
	green = "#a6e3a1",
	teal = "#94e2d5",
	sky = "#89dceb",
	sapphire = "#74c7ec",
	blue = "#89b4fa",
	lavender = "#b4befe",
	text = "#cdd6f4",
	subtext1 = "#bac2de",
	subtext0 = "#a6adc8",
	overlay2 = "#9399b2",
	overlay1 = "#7f849c",
	overlay0 = "#6c7086",
	surface2 = "#585b70",
	surface1 = "#45475a",
	surface0 = "#313244",
	base = "#1e1e2e",
	mantle = "#181825",
	crust = "#11111b",
}
function M.options(config)
	config.status_update_interval = 1000
	config.color_scheme = "Catppuccin Mocha"

	config.animation_fps = 240
	config.max_fps = 240

	config.initial_cols = 115
	config.initial_rows = 28
	config.font = term.font({
		family = "FiraCode Nerd Font",
		weight = "Regular",
		stretch = "Normal",
		style = "Normal",
		harfbuzz_features = { "calt=1", "clig=1", "liga=1" },
		-- scale = 1.0
	})
	config.font_size = 14
	config.window_decorations = "RESIZE"
	-- config.text_background_opacity = 0.3
	-- config.window_background_opacity = 0.618
	config.window_frame = {
		border_left_width = "0px",
		border_right_width = "0px",
		border_bottom_height = "6px",
		border_top_height = "0px",
		border_left_color = M.colors.crust,
		border_right_color = M.colors.crust,
		border_bottom_color = M.colors.crust,
		border_top_color = M.colors.crust,
		-- font_size = 16,
	}
	config.enable_scroll_bar = false
	config.default_cursor_style = "SteadyBar"
	-- config.cursor_blink_rate = 333
	config.inactive_pane_hsb = { saturation = 1.0, brightness = 0.5 }
	config.window_padding = { left = 0, right = 0, top = 0, bottom = 0 }
	config.colors = {
		background = M.colors.crust,
		tab_bar = {
			background = M.colors.crust,
			active_tab = {
				bg_color = M.colors.peach,
				fg_color = M.colors.crust,
			},
			inactive_tab = {
				bg_color = M.colors.blue,
				fg_color = M.colors.base,
			},
		},
	}

	----- Misc
	config.adjust_window_size_when_changing_font_size = false
	config.audible_bell = "Disabled"
	config.exit_behavior = "Close"
	config.window_close_confirmation = "NeverPrompt"
	config.scrollback_lines = 50000
	config.tab_max_width = 9999
	config.hide_tab_bar_if_only_one_tab = false
	config.tab_bar_at_bottom = true
	config.use_fancy_tab_bar = false
	config.show_new_tab_button_in_tab_bar = false
	config.allow_win32_input_mode = true
	config.disable_default_key_bindings = true
end
return M
