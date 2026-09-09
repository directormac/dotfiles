--- This module shall server as source of thruth.

local function get_distro()
  local f = io.open('/etc/os-release', 'r')
  if not f then return 'unknown' end

  local content = f:read('*all')
  f:close()

  -- Extract the ID field from /etc/os-release
  local id = content:match('ID="?([^"\n]+)"?')
  if id then return id:lower() end

  return 'unknown'
end

local is_nixos = os.execute('test -d /nix/store') == 0

local function get_hostname()
  local f = io.open('/etc/hostname', 'r')
  if f then
    local name = f:read('*l')
    f:close()
    return name
  end
  return ''
end

_G.cfg = cfg or {}

_G.modkey = 'SUPER'

-- APPLICATIONS --
local applications = {
  terminal = 'ghostty',
  browser = 'zen-browser',
  fileManager = 'nautilus',
  menu = 'hyprlauncher',
}

local floating_centered_wr = {
  float = true,
  center = true,
  size = { '(monitor_w*0.5)', '(monitor_h*0.5)' },
}

cfg = {
  applications = applications,
  floating_centered_wr = floating_centered_wr,
  hostname = get_hostname(),
  distro = get_distro(),
  is_nixos = is_nixos,
}

return cfg
