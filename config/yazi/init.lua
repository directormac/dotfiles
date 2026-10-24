require('zoxide'):setup({
  update_db = true,
})

require('close-and-restore-tab'):setup()
require('projects'):setup()
require('starship'):setup()
require('git'):setup()

require('whoosh'):setup({
  bookmarks = {
    { tag = "Home", path = "~", key = "h" },
    { tag = "Config", path = "~/.config", key = { "f", "c" } },
    { tag = "Dotfiles", path = "~/.dotfiles", key = "D" },
    { tag = "Downloads", path = "~/Downloads", key = "d" },
    { tag = "Resources", path = "~/Resources", key = "r" },
  },
  jump_notify = false,
  special_keys = {
    create_temp = "<Enter>",
    fuzzy_search = "<Space>",
    history = "<Tab>",
    previous_dir = "<Backspace>",
    project_root = "-",
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
