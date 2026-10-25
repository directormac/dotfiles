--- difftool.yazi
--- Upstream: https://github.com/glassjaw/difftool.yazi
--- Diff 2 selected files/dirs with git difftool / hunk

--- @since 26.8.15

local TITLE = "Difftool"

local DEFAULTS = {
	-- Tool to use when none is passed with `--tool`; nil uses git's `diff.tool`
	tool = nil,
	-- Candidates offered by `--pick`
	tools = { "meld", "vscode", "bc", "vimdiff", "nvimdiff" },
	-- Tools that can't compare directories; directory pairs fall back to one diff per changed file
	per_file_tools = { "vscode" },
	-- Extra tools that run inside the terminal, so Yazi has to hide its UI while they run.
	-- git's built-in terminal tools (vimdiff, nvimdiff, emerge, ...) are detected automatically.
	terminal_tools = {},
}

local function notify(level, s, ...)
	ya.notify {
		title = TITLE,
		content = string.format(s, ...),
		level = level,
		timeout = 5,
	}
end

local function contains(list, value)
	for _, v in ipairs(list) do
		if v == value then
			return true
		end
	end
	return false
end

local get_opts = ya.sync(function(state)
	local opts = {}
	for k, v in pairs(DEFAULTS) do
		if state[k] == nil then
			opts[k] = v
		else
			opts[k] = state[k]
		end
	end
	return opts
end)

local function entry_of(f)
	return f and { path = f.path and tostring(f.path), is_dir = f.cha.is_dir }
end

-- Picks the two things to compare:
--   2 selected                 -> those two, in selection order
--   1 selected + hovered       -> selected vs hovered
--   nothing selected, 2+ tabs  -> hovered in this tab vs hovered in the next tab (lower tab number on the left)
local get_targets = ya.sync(function()
	local tab, targets = cx.active, {}
	for _, f in pairs(tab.selected) do
		targets[#targets + 1] = entry_of(f)
	end

	if #targets == 1 then
		local h = entry_of(tab.current.hovered)
		if h and h.path ~= targets[1].path then
			targets[2] = h
		end
	elseif #targets == 0 and #cx.tabs > 1 then
		local next_idx = cx.tabs.idx % #cx.tabs + 1
		local a, b = entry_of(tab.current.hovered), entry_of(cx.tabs[next_idx].current.hovered)
		if next_idx < cx.tabs.idx then
			a, b = b, a
		end
		if a and b then
			targets = { a, b }
		end
	end
	return targets
end)

-- The tool git would use when none is given, so we know whether it's a terminal tool
local function configured_tool()
	for _, key in ipairs { "diff.tool", "merge.tool" } do
		local output = Command("git"):arg { "config", "--get", key }:output()
		local value = output and output.status.success and output.stdout:gsub("%s+$", "")
		if value and value ~= "" then
			return value
		end
	end
end

-- What git knows about each tool, from `git difftool --tool-help`:
-- { [name] = { available = bool, gui = bool?, custom = bool } }, or nil if the output can't be parsed
local function tool_info()
	local output = Command("git"):arg({ "difftool", "--tool-help" }):env("LC_ALL", "C"):output()
	if not output or not output.status.success then
		return nil
	end

	local tools, section = {}, nil
	for line in output.stdout:gmatch("[^\n]+") do
		if line:find("may be set to one of the following:", 1, true) then
			section = "available"
		elseif line:find("valid, but not currently available:", 1, true) then
			section = "unavailable"
		elseif line:find("^%S") then
			section = nil
		elseif section then
			local name, desc = line:match("^%s+(%S+)%s+(.*)$")
			if name and name:find("%.cmd$") then
				tools[name:sub(1, -5)] = { available = true, custom = true }
			elseif name then
				local gui = desc:find("graphical session", 1, true) ~= nil
				tools[name] = { available = section == "available", gui = gui, custom = false }
			end
		end
	end
	return next(tools) and tools or nil
end

-- Returns an error message if git can't launch `tool`
local function check_tool(tool, info)
	if not info then
		return nil -- couldn't read git's tool list, let git report any problem itself
	elseif not info[tool] then
		return string.format("git doesn't know a difftool called '%s' (see `git difftool --tool-help`)", tool)
	elseif not info[tool].available then
		return string.format(
			"'%s' isn't installed or isn't on PATH. Set its location with:\ngit config --global difftool.%s.path <path>",
			tool,
			tool
		)
	end
end

local function pick_tool(tools)
	local cands = {}
	for i, t in ipairs(tools) do
		cands[i] = { on = i <= 9 and tostring(i) or string.char(string.byte("a") + i - 10), desc = t }
	end
	local idx = ya.which { cands = cands }
	return idx and tools[idx]
end

-- Returns the git arguments and environment that open `tool` on `a` and `b`
local function git_invocation(tool, a, b, per_file)
	local envs = { GIT_DIFFTOOL_NO_PROMPT = "true" }
	if per_file then
		return { "difftool", "--no-index", "--no-prompt", "--tool=" .. tool, "--", a, b }, envs
	end
	-- git's own launcher for `difftool --dir-diff`: opens the tool once on two paths,
	-- honouring difftool.<tool>.path/cmd and the built-in tool definitions
	envs.GIT_DIFFTOOL_DIRDIFF = "true"
	envs.GIT_DIFF_TOOL = tool
	return { "difftool--helper", a, b }, envs
end

local function run_in_terminal(args, envs)
	local cmd = Command("git"):arg(args)
	for k, v in pairs(envs) do
		cmd = cmd:env(k, v)
	end

	local permit = ui.hide()
	local status, err = cmd:stdin(Command.INHERIT):stdout(Command.INHERIT):stderr(Command.INHERIT):status()
	permit:drop()
	if not status then
		return notify("error", "Failed to run git: %s", err)
	end
	-- `git diff --no-index` (per-file mode) exits 1 when the inputs differ
	if status.code ~= 0 and status.code ~= 1 then
		notify("error", "Difftool exited with code %s", status.code)
	end
end

-- GUI tools are started fully detached. Yazi kills a plugin's child process when the plugin
-- lets go of it, and counts one it's still waiting on as an unfinished task (asking to confirm
-- on quit). So start them through a launcher that backgrounds git and exits at once.
local function run_detached(args, envs)
	local cmd
	if ya.target_family() == "windows" then
		cmd = Command("cmd"):arg({ "/c", "start", "", "/b", "git" }):arg(args)
	else
		cmd = Command("sh"):arg({ "-c", 'nohup "$@" >/dev/null 2>&1 &', "sh", "git" }):arg(args)
	end
	for k, v in pairs(envs) do
		cmd = cmd:env(k, v)
	end

	local status, err = cmd:stdin(Command.NULL):stdout(Command.NULL):stderr(Command.NULL):status()
	if not status then
		notify("error", "Failed to run git: %s", err)
	elseif not status.success then
		notify("error", "Failed to start the difftool (exit %s)", status.code)
	end
end

return {
	setup = function(state, opts)
		for k, v in pairs(opts or {}) do
			state[k] = v
		end
	end,

	entry = function(_, job)
		ya.emit("escape", { visual = true })

		local targets = get_targets()
		if #targets ~= 2 then
			return notify(
				"warn",
				"Select exactly 2 files/directories, or select 1 and hover another, "
					.. "or hover one in each of two tabs (got %d)",
				#targets
			)
		end

		local a, b = targets[1], targets[2]
		if not a.path or not b.path then
			return notify("error", "Only local files can be compared")
		elseif a.is_dir ~= b.is_dir then
			return notify("error", "Can't compare a file with a directory")
		end

		local opts = get_opts()
		local tool = job.args.tool
		if not tool and job.args.pick then
			tool = pick_tool(opts.tools)
			if not tool then
				return
			end
		end
		tool = tool or opts.tool or configured_tool()
		if not tool then
			return notify(
				"error",
				"No difftool configured. Set one with:\ngit config --global diff.tool <tool>\nor pass --tool=<tool>"
			)
		end

		local info = tool_info()
		local problem = check_tool(tool, info)
		if problem then
			return notify("error", "%s", problem)
		end

		local per_file = a.is_dir and contains(opts.per_file_tools, tool)
		local args, envs = git_invocation(tool, a.path, b.path, per_file)

		local builtin = info and info[tool]
		local in_terminal = contains(opts.terminal_tools, tool) or (builtin and builtin.gui == false)
		if in_terminal then
			run_in_terminal(args, envs)
		else
			run_detached(args, envs)
		end
	end,
}
