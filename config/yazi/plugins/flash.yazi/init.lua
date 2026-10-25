--- flash.yazi
--- Upstream: https://github.com/sohanemon/flash.yazi
--- Regex-aware 2-key label jump navigation overlay

local KEYS_label = {
	"j",
	"f",
	"d",
	"k",
	"l",
	"h",
	"g",
	"a",
	"s",
	"o",
	"i",
	"e",
	"u",
	"n",
	"c",
	"m",
	"r",
	"p",
	"b",
	"t",
	"w",
	"v",
	"x",
	"y",
	"q",
	"z",
	"I",
	"J",
	"L",
	"H",
	"A",
	"B",
	"Y",
	"D",
	"E",
	"F",
	"G",
	"Q",
	"R",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Z",
	"C",
	"K",
	"M",
	"N",
	"O",
	"P",
	"S",
}

local INPUT_KEY = {
	"A",
	"B",
	"C",
	"D",
	"E",
	"F",
	"G",
	"H",
	"I",
	"J",
	"K",
	"L",
	"M",
	"N",
	"O",
	"P",
	"Q",
	"R",
	"S",
	"T",
	"U",
	"V",
	"W",
	"X",
	"Y",
	"Z",
	"a",
	"b",
	"c",
	"d",
	"e",
	"f",
	"g",
	"h",
	"i",
	"j",
	"k",
	"l",
	"m",
	"n",
	"o",
	"p",
	"q",
	"r",
	"s",
	"t",
	"u",
	"v",
	"w",
	"x",
	"y",
	"z",
	"0",
	"1",
	"2",
	"3",
	"4",
	"5",
	"6",
	"7",
	"8",
	"9",
	"-",
	"_",
	".",
	"<Esc>",
	"<Space>",
	"<Enter>",
	"<Backspace>",
}

local INPUT_CANDS = {
	{ on = "A" },
	{ on = "B" },
	{ on = "C" },
	{ on = "D" },
	{ on = "E" },
	{ on = "F" },
	{ on = "G" },
	{ on = "H" },
	{ on = "I" },
	{ on = "J" },
	{ on = "K" },
	{ on = "L" },
	{ on = "M" },
	{ on = "N" },
	{ on = "O" },
	{ on = "P" },
	{ on = "Q" },
	{ on = "R" },
	{ on = "S" },
	{ on = "T" },
	{ on = "U" },
	{ on = "V" },
	{ on = "W" },
	{ on = "X" },
	{ on = "Y" },
	{ on = "Z" },
	{ on = "a" },
	{ on = "b" },
	{ on = "c" },
	{ on = "d" },
	{ on = "e" },
	{ on = "f" },
	{ on = "g" },
	{ on = "h" },
	{ on = "i" },
	{ on = "j" },
	{ on = "k" },
	{ on = "l" },
	{ on = "m" },
	{ on = "n" },
	{ on = "o" },
	{ on = "p" },
	{ on = "q" },
	{ on = "r" },
	{ on = "s" },
	{ on = "t" },
	{ on = "u" },
	{ on = "v" },
	{ on = "w" },
	{ on = "x" },
	{ on = "y" },
	{ on = "z" },
	{ on = "0" },
	{ on = "1" },
	{ on = "2" },
	{ on = "3" },
	{ on = "4" },
	{ on = "5" },
	{ on = "6" },
	{ on = "7" },
	{ on = "8" },
	{ on = "9" },
	{ on = "-" },
	{ on = "_" },
	{ on = "." },
	{ on = "<Esc>" },
	{ on = "<Space>" },
	{ on = "<Enter>" },
	{ on = "<Backspace>" },
}

local set_re_match = ya.sync(function(state, re_match)
	state.re_match = re_match
end)

local get_re_match_state = ya.sync(function(state)
	return state.re_match
end)

local insert_next_char = ya.sync(function(state, next_char)
	if next_char == nil then
		return
	end
	state.next_char[next_char] = ""
end)

local function get_match_position(name, find_str)
	if find_str == "" or find_str == nil then
		return nil, nil
	end

	local startPos, endPos = {}, {}
	local startp, endp
	name = string.lower(name)
	local is_match_char = false

	if not get_re_match_state() then
		local i = 1
		local j = 1
		local real_start_pos = 0
		local real_end_pos = 0
		local real_index = 1
		find_str = string.lower(find_str)
		local wide_char_name = {}
		local wide_char_match_begin = 0
		local index_wide_char
		for utf8_char in string.gmatch(name, "[%z\1-\127\194-\244][\128-\191]*") do
			table.insert(wide_char_name, utf8_char)
		end
		while j <= #wide_char_name do
			index_wide_char = wide_char_name[j]

			is_match_char = find_str:sub(i, i) == index_wide_char

			if real_start_pos == 0 and is_match_char then
				real_start_pos = real_index
				wide_char_match_begin = j
			end

			if real_start_pos ~= 0 and is_match_char then
				if i == #find_str then
					real_end_pos = real_index
					table.insert(startPos, real_start_pos)
					table.insert(endPos, real_end_pos)
					insert_next_char(wide_char_name[j + 1])
					i = 1
					wide_char_match_begin = 0
					real_end_pos = 0
					real_start_pos = 0
				else
					i = i + 1
				end
				real_index = real_index + 1
			elseif real_start_pos ~= 0 and not is_match_char then
				i = 1
				j = wide_char_match_begin
				real_index = real_start_pos + 1
				real_start_pos = 0
				wide_char_match_begin = 0
			else
				real_index = real_index + 1
			end

			j = j + 1
		end
	else -- re match mode
		endp = 0
		while true do
			startp, endp = string.find(name, find_str, endp + 1)
			if not startp then
				break
			end
			table.insert(startPos, startp)
			table.insert(endPos, endp)
		end
	end

	if #startPos > 0 then
		return startPos, endPos
	else
		return nil, nil
	end
end

local get_first_match_label = ya.sync(function(state)
	if state.match == nil then
		return nil
	end

	for url, _ in pairs(state.match) do
		return #state.match[url].key > 0 and state.match[url].key[1] or nil
	end

	return nil
end)

local render_match_label = ya.sync(function(state, url, name, file)
	local span = {}
	local key = {}
	local i = 1
	if state.match[url].key and #state.match[url].key > 0 then
		key = state.match[url].key
	end

	local startPos = state.match[url].startPos
	local endPos = state.match[url].endPos

	if file.is_hovered then
		table.insert(span, ui.Span(name:sub(1, startPos[1] - 1)))
	else
		table.insert(span, ui.Span(name:sub(1, startPos[1] - 1)):fg(state.color_unmatched))
	end

	while i <= #startPos do
		table.insert(span, ui.Span(name:sub(startPos[i], endPos[i])):fg(state.color_match_fg):bg(state.color_match_bg))
		if i <= #key then
			table.insert(span, ui.Span(key[i]):fg(state.color_label_fg):bg(state.color_label_bg))
		end
		if i + 1 <= #startPos then
			if file.is_hovered then
				table.insert(span, ui.Span(name:sub(endPos[i] + 1, startPos[i + 1] - 1)))
			else
				table.insert(span, ui.Span(name:sub(endPos[i] + 1, startPos[i + 1] - 1)):fg(state.color_unmatched))
			end
		end
		i = i + 1
	end

	if file.is_hovered then
		table.insert(span, ui.Span(name:sub(endPos[i - 1] + 1, #name)))
	else
		table.insert(span, ui.Span(name:sub(endPos[i - 1] + 1, #name)):fg(state.color_unmatched))
	end
	return span
end)

local update_match_table = ya.sync(function(state, pane, folder, convert_pattern)
	if not folder then
		return
	end

	for i, file in ipairs(folder.window) do
		local name = file.name:gsub("\r", "?", 1)
		local url = tostring(file.url)
		local startPos, endPos = get_match_position(name, convert_pattern)
		if startPos then
			state.match[url] =
				{ key = {}, startPos = startPos, endPos = endPos, isdir = file.cha.is_dir, pane = pane, cursorPos = i }
		end
	end
end)

local record_matches = ya.sync(function(state, patterns)
	local exist_match = false

	if state.match == nil then
		state.match = {}
	end
	if state.next_char == nil then
		state.next_char = {}
	end

	for _, pattern in ipairs(patterns) do
		update_match_table("current", cx.active.current, pattern)
		if not state.opt_only_current then
			update_match_table("parent", cx.active.parent, pattern)
			update_match_table("preview", cx.active.preview.folder, pattern)
		end
	end

	local valid_label = {}
	for _, value in ipairs(KEYS_label) do
		if not state.opt_enable_capital_label and string.byte(value) > 64 and string.byte(value) < 91 then
			goto nextlabel
		end
		if state.next_char[string.lower(value)] == nil then
			table.insert(valid_label, value)
		end
		::nextlabel::
	end

	local i = 1
	for url, _ in pairs(state.match) do
		exist_match = true
		local j = 1
		while j <= #state.match[url].startPos do
			table.insert(state.match[url].key, valid_label[i])
			i = i + 1
			j = j + 1
		end
	end

	if cx.active.preview.folder then
		ya.emit("peek", { force = true })
	end
	ui.render()

	return exist_match
end)

local toggle_flash_ui = ya.sync(function(st)
	if st.highlights or st.status_flash_id then
		Status:children_remove(st.status_flash_id)
		Entity.highlights, st.highlights, st.status_flash_id = st.highlights, nil, nil
		if cx.active.preview.folder then
			ya.emit("peek", { force = true })
		end
		ui.render()
		return
	end

	st.highlights = Entity.highlights
	Entity.highlights = function(self)
		local file = self._file
		local spans = {}
		local name = file.name:gsub("\r", "?", 1)
		local url = tostring(file.url)
		if st.match and st.match[url] then
			spans = render_match_label(url, name, file)
		elseif file.is_hovered then
			spans = { ui.Span(name) }
		else
			spans = { ui.Span(name):fg(st.color_unmatched) }
		end
		return ui.Line(spans)
	end

	local function status_flash(self)
		local style = self:style()
		local match_pattern = (st.match_pattern and st.opt_show_search_in_statusbar) and ":" .. st.match_pattern or ""
		return ui.Line({ ui.Span("[Flash]" .. match_pattern .. " "):style(style.main) })
	end
	st.status_flash_id = Status:children_add(status_flash, 1001, Status.LEFT)

	if cx.active.preview.folder then
		ya.emit("peek", { force = true })
	end
end)

local get_url_by_label = ya.sync(function(state, final_input_str)
	if state.backouting then
		state.backouting = false
		return nil
	end
	if not state.match then
		return nil
	end
	for url, _ in pairs(state.match) do
		for _, value in ipairs(state.match[url].key) do
			if value == final_input_str then
				return url
			end
		end
	end
	return nil
end)

local process_input = ya.sync(function(state, patterns, final_input_str)
	local url = get_url_by_label(final_input_str)
	if url then
		if not state.args_autocd and state.match[url].pane == "current" then
			local folder = cx.active.current
			ya.emit("arrow", { state.match[url].cursorPos - folder.cursor - 1 + folder.offset })
		elseif state.args_autocd and state.match[url].isdir then
			ya.emit("cd", { url })
		else
			ya.emit("reveal", { url })
		end
		return true, true
	end

	state.match = nil
	state.next_char = nil

	local exist_match = record_matches(patterns)

	ui.render()
	if not exist_match and (state.re_match or patterns[1] ~= "") and state.opt_auto_exit_when_unmatch then
		return true, exist_match
	else
		return false, exist_match
	end
end)

local clear_flash_state = ya.sync(function(state)
	state.match = nil
	state.next_char = nil
	state.backouting = nil
	state.match_pattern = nil
	ui.render()
end)

local set_flash_opts_default = ya.sync(function(state)
	if state.color_unmatched == nil then
		state.color_unmatched = "#515879"
	end
	if state.color_match_fg == nil then
		state.color_match_fg = "#FFFFFF"
	end
	if state.color_match_bg == nil then
		state.color_match_bg = "#3E68D7"
	end
	if state.color_label_fg == nil then
		state.color_label_fg = "#FFFFFF"
	end
	if state.color_label_bg == nil then
		state.color_label_bg = "#FF007C"
	end
	if state.opt_only_current == nil then
		state.opt_only_current = false
	end
	if state.opt_search_patterns == nil then
		state.opt_search_patterns = {}
	end
	if state.opt_show_search_in_statusbar == nil then
		state.opt_show_search_in_statusbar = false
	end
	if state.opt_auto_exit_when_unmatch == nil then
		state.opt_auto_exit_when_unmatch = true
	end
	if state.opt_enable_capital_label == nil then
		state.opt_enable_capital_label = false
	end
	return state.opt_search_patterns
end)

local backout_last_input = ya.sync(function(state, input_str)
	local final_input_str = input_str:sub(-2, -2)
	input_str = input_str:sub(1, -2)
	state.backouting = true
	state.match_pattern = input_str
	ui.render()
	return input_str, final_input_str
end)

local flush_input_in_statusbar = ya.sync(function(state, input_str)
	if state.re_match then
		state.match_pattern = "[~]"
	else
		state.match_pattern = input_str
	end
	ui.render()
end)

local set_args_default = ya.sync(function(state, args)
	if args[1] ~= nil and args[1] == "autocd" then
		state.args_autocd = true
	else
		state.args_autocd = false
	end
end)

return {
	setup = function(state, opts)
		if opts ~= nil and opts.color_unmatched ~= nil then
			state.color_unmatched = opts.color_unmatched
		end
		if opts ~= nil and opts.color_match_fg ~= nil then
			state.color_match_fg = opts.color_match_fg
		end
		if opts ~= nil and opts.color_match_bg ~= nil then
			state.color_match_bg = opts.color_match_bg
		end
		if opts ~= nil and opts.color_label_fg ~= nil then
			state.color_label_fg = opts.color_label_fg
		end
		if opts ~= nil and opts.color_label_bg ~= nil then
			state.color_label_bg = opts.color_label_bg
		end
		if opts ~= nil and opts.only_current ~= nil then
			state.opt_only_current = opts.only_current
		end
		if opts ~= nil and opts.search_patterns ~= nil then
			state.opt_search_patterns = opts.search_patterns
		end
		if opts ~= nil and opts.show_search_in_statusbar ~= nil then
			state.opt_show_search_in_statusbar = opts.show_search_in_statusbar
		end
		if opts ~= nil and opts.auto_exit_when_unmatch ~= nil then
			state.opt_auto_exit_when_unmatch = opts.auto_exit_when_unmatch
		end
		if opts ~= nil and opts.enable_capital_label ~= nil then
			state.opt_enable_capital_label = opts.enable_capital_label
		end
	end,

	entry = function(_, job)
		local opt_search_patterns = set_flash_opts_default()
		set_args_default(job.args)
		toggle_flash_ui()

		local input_str = ""
		local patterns = {}
		local final_input_str = ""
		while true do
			local cand = ya.which({ cands = INPUT_CANDS, silent = true })
			if cand == nil then
				goto continue
			end
			if INPUT_KEY[cand] == "<Esc>" then
				break
			end

			if INPUT_KEY[cand] == "<Enter>" then
				final_input_str = get_first_match_label()
				patterns = ""
			elseif INPUT_KEY[cand] == "<Space>" then
				final_input_str = ""
				input_str = ""
				patterns = opt_search_patterns
				set_re_match(true)
			elseif INPUT_KEY[cand] == "<Backspace>" then
				input_str, final_input_str = backout_last_input(input_str)
				patterns = { input_str }
				set_re_match(false)
			else
				final_input_str = INPUT_KEY[cand]
				input_str = input_str .. string.lower(INPUT_KEY[cand])
				patterns = { input_str }
				set_re_match(false)
			end

			::reset::
			flush_input_in_statusbar(input_str)

			local want_exit, is_match = process_input(patterns, final_input_str)
			if want_exit then
				break
			end

			if not is_match and get_re_match_state() then
				break
			elseif not is_match and input_str ~= "" then
				input_str, final_input_str = backout_last_input(input_str)
				patterns = { input_str }
				goto reset
			end
			::continue::
		end

		clear_flash_state()
		toggle_flash_ui()
	end,
}
