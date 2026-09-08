require("zoxide"):setup({
	update_db = true,
})

-- require("autosession"):setup()

function Linemode:size_and_mtime()
	local year = os.date("%Y")
	local time = math.floor(self._file.cha.mtime or 0)

	if time == 0 then
		time = ""
	elseif os.date("%Y", time) == year then
		time = os.date("%b %d %H:%M", time)
	else
		time = os.date("%b %d  %Y", time)
	end

	local size = self._file:size()
	return ui.Line(string.format("%s %s", size and ya.readable_size(size) or "-", time))
end
