--- yafg.yazi (Yet Another FG) with Television (tv) & fzf support
--- Upstream: https://github.com/XYenon/yafg.yazi
--- Enhanced with tv cli (television) integration for live ripgrep text/file searching

local M = {
	backend = "tv", -- "tv" or "fzf"
	toggle_mode_key = "ctrl-t",
	editor = os.getenv("EDITOR") or "nvim",
	args = {},
	file_arg_format = "+{row} {file}",
}

local cwd = ya.sync(function()
	return cx.active.current.cwd
end)

local sync_self = ya.sync(function()
	local self = {}
	for key, value in pairs(M) do
		if type(value) ~= "function" then
			self[key] = value
		end
	end
	return self
end)

local function format_key_for_display(key)
	return (key:gsub("[^-]+", function(part)
		return part:sub(1, 1):upper() .. part:sub(2)
	end))
end

function M:setup(opts)
	opts = opts or {}
	self.backend = opts.backend or self.backend
	self.toggle_mode_key = opts.toggle_mode_key or self.toggle_mode_key
	self.editor = opts.editor or self.editor
	self.args = opts.args or self.args
	self.file_arg_format = opts.file_arg_format or self.file_arg_format
end

function M:entry(job)
	ya.emit("escape", { visual = true })

	local args = job.args or {}
	local mode = args.mode or args[1] or "text" -- "text" or "files"
	local use_tv = (args.backend == "tv") or (self.backend == "tv" and args.backend ~= "fzf")

	local _permit = ui.hide()
	local current_cwd = cwd()

	local output, err
	if use_tv then
		output, err = M.run_tv(current_cwd, mode)
		if not output and err and tostring(err):find("not found") then
			-- Fallback to fzf if tv binary missing
			output, err = M.run_fzf(current_cwd)
		end
	else
		output, err = M.run_fzf(current_cwd)
	end

	_permit:drop()

	if not output then
		if err then
			return ya.notify({ title = "Yafg", content = tostring(err), timeout = 5, level = "error" })
		end
		return
	end

	local results = M.split_results(current_cwd, output)
	if #results == 0 then
		return
	elseif #results == 1 then
		local first_url = results[1][1]
		local cha = fs.cha(first_url)
		if cha and cha.is_dir then
			ya.emit("cd", { Url(first_url) })
			return
		end
		-- Reveal hovered file in Yazi
		ya.emit("reveal", { Url(first_url) })

		if not args.edit then
			return
		end
	end

	local ss = sync_self()
	local cmd_args = {}
	for i, arg in ipairs(ss.args) do
		cmd_args[i] = ya.quote(arg)
	end
	local file_args = {}
	for i, result in ipairs(results) do
		local quoted_file = ya.quote(tostring(result[1]))
		local arg = string.gsub(ss.file_arg_format, "{file}", function()
			return quoted_file
		end)
		arg = string.gsub(arg, "{row}", tostring(result[2] or 1))
		arg = string.gsub(arg, "{col}", tostring(result[3] or 1))
		file_args[i] = arg
	end

	local cmd = ss.editor .. " " .. table.concat(cmd_args, " ") .. " " .. table.concat(file_args, " ")
	os.execute(cmd)
end

function M.run_tv(current_cwd, mode)
	local channel = mode == "files" and "files" or "text"
	local child, err = Command("tv")
		:arg(channel)
		:cwd(tostring(current_cwd))
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()

	if not child then
		return nil, Err("Failed to spawn `tv`: %s", err)
	end

	local output, wait_err = child:wait_with_output()
	if not output then
		return nil, Err("Cannot read `tv` output: %s", wait_err)
	elseif not output.status.success and output.status.code ~= 130 then
		return nil, Err("`tv` exited with error code %s", output.status.code)
	end

	return output.stdout, nil
end

function M.run_fzf(current_cwd)
	local ss = sync_self()
	local cmd_args = "TOGGLE_KEY="
		.. ya.quote(ss.toggle_mode_key)
		.. " DISPLAY_TOGGLE_KEY="
		.. ya.quote(format_key_for_display(ss.toggle_mode_key))
		.. [=[
        RG_PREFIX=$'rg --column --line-number --no-heading --color=always --smart-case --field-match-separator \x1f:\x1e'
        PREVIEW='bat --color=always --highlight-line={2} -- {1}'
        fzf --ansi --disabled --multi \
            --bind "start:reload:${RG_PREFIX} {q}" \
            --bind "change:reload:sleep 0.1; ${RG_PREFIX} {q} || true" \
            --bind "${TOGGLE_KEY}:transform:[[ ! \${FZF_PROMPT} =~ ripgrep ]] &&
                   echo 'rebind(change)+change-prompt(1. ripgrep> )+disable-search+reload:${RG_PREFIX} \{q} || true' ||
                   echo 'unbind(change)+change-prompt(2. fzf> )+enable-search+reload:${RG_PREFIX} \"\" || true'" \
            --color "hl:-1:underline,hl+:-1:underline:reverse" \
            --prompt '1. ripgrep> ' \
            --delimiter '\x1f:\x1e' \
            --nth '4..' \
            --header "${DISPLAY_TOGGLE_KEY}: Switch between ripgrep/fzf" \
            --preview "${PREVIEW}" \
            --preview-window 'up,60%,~3,+{2}+3/2'
        ]=]
	local child, err = Command("bash")
		:arg({ "-c", cmd_args })
		:env("SHELL", "bash")
		:cwd(tostring(current_cwd))
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:spawn()

	if not child then
		return nil, Err("Failed to start `fzf`, error: %s", err)
	end

	local output, wait_err = child:wait_with_output()
	if not output then
		return nil, Err("Cannot read `fzf` output, error: %s", wait_err)
	elseif not output.status.success and output.status.code ~= 130 then
		return nil, Err("`fzf` exited with error code %s", output.status.code)
	end
	return output.stdout, nil
end

local field_sep = "\31:\30"

function M.split_results(current_cwd, output)
	local t = {}
	for raw_line in output:gmatch("[^\r\n]+") do
		local line = raw_line:gsub("^%s+", ""):gsub("%s+$", "")
		if line ~= "" then
			-- Format 1: fzf field_sep delimiter
			local file, row, col = line:match("^(.-)" .. field_sep .. "(%d+)" .. field_sep .. "(%d+)" .. field_sep)
			-- Format 2: tv / ripgrep "file:row:col:..." or "file:row:..."
			if not file then
				file, row, col = line:match("^(.-):(%d+):(%d+):")
			end
			if not file then
				file, row = line:match("^(.-):(%d+):")
				col = 1
			end
			if not file then
				file = line
				row = 1
				col = 1
			end
			if file and file ~= "" then
				local u = Url(file)
				t[#t + 1] = {
					u.is_absolute and u or current_cwd:join(u),
					tonumber(row) or 1,
					tonumber(col) or 1,
				}
			end
		end
	end
	return t
end

return M
