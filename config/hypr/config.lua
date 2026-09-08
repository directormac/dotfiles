--- This module shall server as source of thruth.

local function get_hostname()
  local f = io.open("/etc/hostname", "r")
  if f then
    local name = f:read("*l")
    f:close()
    return name
  end
  return ""
end

_G.cfg = cfg or {}
_G.cfg.hostname = get_hostname()

-- Check if we are running under UWSM to properly prefix autostart commands
_G.cfg.is_uwsm = os.getenv("UWSM_SESSION_ID") ~= nil
_G.cfg.uwsm_prefix = _G.cfg.is_uwsm and "uwsm app -- " or ""

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
}

return cfg
