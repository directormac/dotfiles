--- bypass.yazi
--- Upstream: https://github.com/Rolv-Apneseth/bypass.yazi
--- Automatically skip/bypass single-child directories when navigating

-- `ya.emit` as of 25.5.28
local emit = ya.emit or ya.manager_emit

---Returns the loading state of the current directory
---@type fun(): boolean
local is_directory_loading = ya.sync(function(_)
	local ok, res = pcall(cx.active.current.stage)
	if ok then
		return not res
	else
		return cx.active.current.stage.is_loading
	end
end)

---Enter hovered item if it is a directory
---@type fun(use_smart_enter: boolean): boolean
local initial = ya.sync(function(_, use_smart_enter)
	local hovered = cx.active.current.hovered
	if hovered == nil then
		return false
	end

	if not hovered.cha.is_dir then
		if use_smart_enter then
			emit("open", { hovered = true })
		end
		return false
	end

	emit("enter", { hovered = true })
	return true
end)

---Enter hovered item if it is a directory and is the only item in the parent
---@type fun(): boolean
local bypass = ya.sync(function(_)
	local hovered = cx.active.current.hovered
	if hovered == nil or not hovered.cha.is_dir or #cx.active.current.files > 1 then
		return false
	end

	emit("enter", { hovered = true })
	return true
end)

---Leave the CWD, if the CWD has a parent
---@type fun(): boolean
local initial_rev = ya.sync(function(_)
	if cx.active.parent == nil then
		return false
	end

	emit("leave", {})
	return true
end)

---Leave the CWD, if the CWD has a parent and contains only one item
---@type fun(): boolean
local bypass_rev = ya.sync(function(_)
	if cx.active.parent == nil or #cx.active.current.files > 1 then
		return false
	end

	emit("leave", {})
	return true
end)

return {
	entry = function(_, job)
		local args = job.args or job
		local use_smart_enter = args and args[1] == "smart-enter"
		local is_reverse = args and args[1] == "reverse"

		local run = is_reverse and initial_rev() or initial(use_smart_enter)

		while run do
			while is_directory_loading() do
				ya.sleep(0.002)
			end
			run = is_reverse and bypass_rev() or bypass()
		end
	end,
}
