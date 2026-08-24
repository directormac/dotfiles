local Icons = require "utils.class.icon"
local fs = require("utils.fn").fs

local Config = {}

if fs.platform().is_win then
  -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
  Config.wsl_domains = {}
end

Config.default_cwd = fs.home()

-- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
Config.ssh_domains = {}

-- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
Config.unix_domains = {}

return Config
