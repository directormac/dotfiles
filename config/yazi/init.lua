require('zoxide'):setup({
  update_db = true,
})

require('close-and-restore-tab'):setup()
require('projects'):setup({})
require('starship'):setup({
  -- Hide flags (such as filter, find and search). This can be beneficial for starship themes
  -- which are intended to go across the entire width of the terminal.
  hide_flags = true,
  -- Whether to place flags after the starship prompt. False means the flags will be placed before the prompt.
  flags_after_prompt = true,
  -- Custom starship configuration file to use
  -- config_file = "~/.config/starship_full.toml", -- Default: nil
  -- Whether to enable support for starship's right prompt (i.e. `starship prompt --right`).
  show_right_prompt = false,
  -- Whether to hide the count widget, in case you want only your right prompt to show up. Only has
  -- an effect when `show_right_prompt = true`
  hide_count = false,
  -- Separator to place between the right prompt and the count widget. Use `count_separator = ""`
  -- to have no space between the widgets.
  count_separator = ' ',
})
-- Git and Supaline (multi-column linemode with git signs and conditional size)
local supaline = require("supaline")

-- Only show file size if >= 1MB
supaline.column("size_over_1mb", {
  width = 8,
  align = "right",
  render = function(file, ctx)
    local s = file:size()
    if s and s >= 1048576 then
      return ya.readable_size(s), ctx.style
    end
    return "", ctx.style
  end,
})

require("git"):setup({ order = 1500 })

supaline:setup({
  linemodes = {
    detail = { "size_over_1mb", "mtime" },
  },
  toggles = { git = 1500 },
})

-- Responsive layout: vertical stacking on narrow terminals (<90 cols)
require("responsive-layout"):setup({
  wide_min = 90,
  split = 0.5,
  divider = "─",
})

-- Directory & tab preference persistence
require("keep-preferences"):setup()

-- Centered media previews & mediainfo
require("center-media"):setup()

-- Difftool with hunk integration
require("difftool"):setup({
  tool = "hunk",
  tools = { "hunk", "nvimdiff", "vimdiff" },
  terminal_tools = { "hunk", "nvimdiff", "vimdiff" },
})

-- FFmpeg media statistics linemode
require("ffmpeg-stats"):setup({
  duration = false,
  resolution = false,
  codec = false,
  fps = false,
  bitrate = false,
  audio_codec = false,
  audio_channels = false,
  format = false,
  aspect = false,
})

-- Archive mount
require("archive-mount"):setup()

-- SSHFS mounting
require("sshfs"):setup({
  mount_dir = os.getenv("HOME") .. "/mnt",
})

-- Yafg with Television (tv) integration
require("yafg"):setup({
  backend = "tv",
  editor = os.getenv("EDITOR") or "nvim",
  file_arg_format = "+{row} {file}",
})
require('whoosh'):setup({
  bookmarks = {
    { tag = 'Home', path = '~', key = 'h' },
    { tag = 'Config', path = '~/.config', key = { 'f', 'c' } },
    { tag = 'Code', path = '~/Code', key = { 'f', 'C' } },
    { tag = 'Dotfiles', path = '~/.dotfiles', key = 'D' },
    { tag = 'Downloads', path = '~/Downloads', key = 'd' },
    { tag = 'Resources', path = '/mnt/local/resources', key = 'r' },
  },
  jump_notify = false,
  special_keys = {
    create_temp = '<Enter>',
    fuzzy_search = '<Space>',
    history = '<Tab>',
    previous_dir = '<Backspace>',
    project_root = '-',
  },
})

function Linemode:size_and_mtime()
  local year = os.date('%Y')
  local time = math.floor(self._file.cha.mtime or 0)

  if time == 0 then
    time = ''
  elseif os.date('%Y', time) == year then
    time = os.date('%b %d %H:%M', time)
  else
    time = os.date('%b %d  %Y', time)
  end

  local size = self._file:size()
  return ui.Line(string.format('%s %s', size and ya.readable_size(size) or '-', time))
end
