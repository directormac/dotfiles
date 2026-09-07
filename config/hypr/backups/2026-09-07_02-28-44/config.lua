--- This module shall server as source of thruth.

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
}

return cfg
