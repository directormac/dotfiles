--- archive-mount.yazi
--- Upstream: https://github.com/rokokol/archive-mount.yazi
--- Mounts archives as folders via archivemount

--- @since 26.9.1

local M = {}

function M.pid(stat) return tonumber(stat:match "^(%d+)") end

function M.inside(path, mount) return path == mount or path:sub(1, #mount + 1) == mount .. "/" end

function M.unused(mounts, cwds)
	local left = {}
	for _, mount in ipairs(mounts) do
		local used = false
		for _, cwd in ipairs(cwds) do
			used = used or M.inside(cwd, mount)
		end
		if not used then left[#left + 1] = mount end
	end
	return left
end

function M.serves(cmdline, mount)
	local args = {}
	for arg in cmdline:gmatch "([^%z]*)%z" do
		args[#args + 1] = arg
	end
	if #args == 0 or not args[1]:match "archivemount$" then return false end
	for i = 2, #args do
		if args[i] == mount then return true end
	end
	return false
end

function M.missing(err) return err ~= nil and err.code == 2 end

local function read(path)
	local file = io.open(path)
	if not file then return "" end
	local text = file:read "a"
	file:close()
	return text
end

local function base() return (os.getenv "XDG_RUNTIME_DIR" or "/tmp") .. "/yazi-archives" end

-- The plugin runs in the Yazi process, so /proc/self identifies its owner
local function own() return base() .. "/" .. tostring(M.pid(read "/proc/self/stat")) end

local function fail(content)
	ya.notify { title = "Archive", content = content, level = "error", timeout = 5 }
end

local function run(cmd, args)
	local output, err = Command(cmd):arg(args):stdout(Command.PIPED):stderr(Command.PIPED):output()
	if not output then
		if M.missing(err) then
			return nil,
				"Cannot find "
					.. cmd
					.. ". Install the dependencies listed in archive-mount.yazi's README"
		end
		return nil, tostring(err)
	elseif not output.status.success then
		return nil, output.stderr
	end
	return output.stdout
end

local mounted = ya.sync(function(self) return self.mounted or {} end)

local remember = ya.sync(function(self, mount, entry)
	self.mounted = self.mounted or {}
	self.mounted[mount] = entry
end)

-- Use the archive previewer match instead of a separate list of archive types
local hovered = ya.sync(function()
	local h = cx.active.current.hovered
	if not h then return end
	local iterator, state, index =
		pairs(rt.plugin.previewers:match { file = h, mime = h:mime() or "" })
	local _, previewer = iterator(state, index)
	return tostring(h.url), h.name, previewer ~= nil and previewer.name == "archive"
end)

local cwds = ya.sync(function()
	local list = {}
	for i = 1, #cx.tabs do
		list[i] = tostring(cx.tabs[i].current.cwd)
	end
	return list, tostring(cx.active.current.cwd)
end)

local function mtime(path)
	local cha = fs.cha(Url(path))
	return cha and cha.mtime
end

-- archivemount forks, so its initial command does not give the server PID
local function server(mount)
	for _, dir in ipairs(fs.read_dir(Url "/proc", {}) or {}) do
		if dir.name:match "^%d+$" and M.serves(read("/proc/" .. dir.name .. "/cmdline"), mount) then
			return dir.name
		end
	end
end

-- archivemount writes after unmount, in its own process
local function unmount(mount, entry)
	run("fusermount3", { "-uz", mount })
	if entry and entry.edit and entry.pid then
		while fs.cha(Url("/proc/" .. entry.pid)) do
			ya.sleep(0.2)
		end
		if mtime(entry.archive) ~= entry.mtime then
			local name = entry.archive:match "[^/]+$"
			ya.notify {
				title = "Archive",
				content = string.format("Saved %s, the old one is %s.orig", name, name),
				level = "info",
				timeout = 5,
			}
		end
	end
	fs.remove("dir", Url(mount))
end

-- Yazi has no exit hook. A separate session also survives a terminal hangup
local WATCH = [[
yazi=$1 mount=$2 archive=$3 server=$4 before=$5
while kill -0 "$yazi" 2>/dev/null && mountpoint -q "$mount"; do sleep 1; done
mountpoint -q "$mount" || exit 0
fusermount3 -u "$mount" || exit 1
tail --pid="$server" -f /dev/null
rmdir "$mount" 2>/dev/null
name=${archive##*/}
if [ "$(stat -c %Y "$archive")" != "$before" ]; then
  notify-send Archive "Saved $name, the old one is $name.orig"
fi
]]

local function watch(mount, entry)
	Command("setsid")
		:arg({ "-f", "sh", "-c", WATCH, "archive-mount-watch" })
		:arg({ tostring(M.pid(read "/proc/self/stat")), mount, entry.archive, entry.pid })
		:arg({ string.format("%d", math.floor(entry.mtime)) })
		:stdin(Command.NULL)
		:stdout(Command.NULL)
		:stderr(Command.NULL)
		:status()
end

local function open(edit)
	local archive, name, is_archive = hovered()
	if not archive or not is_archive then return fail "Hover an archive to open" end
	for mount, entry in pairs(mounted()) do
		if entry.archive == archive and fs.cha(Url(mount)) then
			-- Separate mounts of one archive would show separate edits
			if entry.edit ~= edit then
				return fail(
					"The archive is open "
						.. (entry.edit and "for editing" or "read-only")
						.. " already"
				)
			end
			return ya.emit("cd", { Url(mount) })
		end
	end

	-- fs.unique requires an existing parent and creates the directory it names
	local _, err = fs.create("dir_all", Url(own()))
	local mount
	if not err then
		mount, err = fs.unique("dir", Url(own() .. "/" .. name))
	end
	if err then return fail(tostring(err)) end
	mount = tostring(mount)
	local entry = { archive = archive, edit = edit }
	if edit then
		-- Both paths are absolute, so neither reads as an option
		entry.mtime = mtime(archive)
		_, err = run("archivemount", { archive, mount })
		entry.pid = not err and server(mount) or nil
	else
		_, err = run("fuse-archive", { "--", archive, mount })
	end
	if err then
		fs.remove("dir", Url(mount))
		return fail(err)
	end
	remember(mount, entry)
	if entry.pid then watch(mount, entry) end
	ya.emit("cd", { Url(mount) })
end

local function sweep()
	local self = own()
	for _, dir in ipairs(fs.read_dir(Url(base()), {}) or {}) do
		local path = tostring(dir.url)
		if path ~= self and dir.name:match "^%d+$" and not fs.cha(Url("/proc/" .. dir.name)) then
			for _, left in ipairs(fs.read_dir(dir.url, {}) or {}) do
				unmount(tostring(left.url))
			end
			fs.remove("dir", dir.url)
		end
	end
end

local function tidy()
	sweep()
	local tabs, active = cwds()
	local archives, list = mounted(), {}
	for mount in pairs(archives) do
		list[#list + 1] = mount
	end
	for _, mount in ipairs(M.unused(list, tabs)) do
		-- Unmount can wait for a write. Remove the entry before another tidy can see it
		remember(mount, nil)
		if active == own() then ya.emit("reveal", { Url(archives[mount].archive) }) end
		unmount(mount, archives[mount])
	end
end

function M.setup(_)
	ps.sub("cd", function() ya.emit("plugin", { "archive-mount", "tidy" }) end)
end

function M.entry(_, job)
	local action = job.args[1]
	if action == "open" then
		open(job.args.edit == true)
	elseif action == "tidy" then
		tidy()
	else
		fail("Unknown action: " .. tostring(action))
	end
end

return M
