--@class Utils
local M = {}

--@class Wezterm
local term = require("wezterm")

--- Icons

M.Icon.Vim = ""

M.Icon.Bash = term.nerdfonts.md_bash

M.Icon.Git = term.nerdfonts.md_git

M.Icon.Admin = term.nerdfonts.md_lightning_bolt

M.Icon.UnseenNotification = term.nerdfonts.cod_circle_small_filled

M.Icon.Numbers = {
	term.nerdfonts.md_numeric_1,
	term.nerdfonts.md_numeric_2,
	term.nerdfonts.md_numeric_3,
	term.nerdfonts.md_numeric_4,
	term.nerdfonts.md_numeric_5,
	term.nerdfonts.md_numeric_6,
	term.nerdfonts.md_numeric_7,
	term.nerdfonts.md_numeric_8,
	term.nerdfonts.md_numeric_9,
	term.nerdfonts.md_numeric_10,
}

-- Functions

---Equivalent to POSIX `basename(3)`
---@param path string Any string representing a path.
---@return string str The basename string.
---
---```lua
----- Example usage
---local name = fn.basename("/foo/bar") -- will be "bar"
---local name = fn.basename("C:\\foo\\bar") -- will be "bar"
---```
M.basename = function(path)
	local trimmed_path = path:gsub("[/\\]*$", "") ---Remove trailing slashes from the path
	local index = trimmed_path:find("[^/\\]*$") ---Find the last occurrence of '/' in the path

	return index and trimmed_path:sub(index) or trimmed_path
end

return M
