up() {
  local d=""
  # If no argument is provided, default to 1 level up
  local limit=${1:-1}

  for i in {1..$limit}; do
    d+="../"
  done

  cd "$d"
}

listening() {
  lsof -i -n -P | grep --color=auto \
    --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} TCP |
    grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} LISTEN
}

extract() {
  if [ -f "$1" ]; then
    case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz) tar xzf "$1" ;;
    *.bz2) bunzip2 "$1" ;;
    *.rar) unrar x "$1" ;;
    *.gz) gunzip "$1" ;;
    *.tar) tar xf "$1" ;;
    *.tbz2) tar xjf "$1" ;;
    *.tgz) tar xzf "$1" ;;
    *.zip) unzip "$1" ;;
    *.Z) uncompress "$1" ;;
    *.7z) 7z x "$1" ;;
    *) echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

# Sesh
# https://github.com/joshmedeski/sesh

# Sesh function
function t() {
  local session
  if [[ -n "$1" ]]; then
    sesh connect "$1"
    return
  fi
  session=$(sesh list --icons | fzf --ansi --prompt='⚡  ' --border-label=' sesh ' --header='  ^a all ^t tmux ^g configs ^x zoxide ^d tmux <ctrl-c>...' \
    --bind 'tab:up,btab:down' \
    --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
    --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
    --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
    --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
    --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .git .)' \
    --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)')
  [[ -n "$session" ]] && sesh connect "$session"
}

# Sesh Keybind (Alt-s)
zle -N t
bindkey '\es' t

function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    zle reset-prompt >/dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

zle -N sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions

# https://github.com/beauwilliams/awesome-fzf

function fzf-rm() {
  if [[ "$#" -eq 0 ]]; then
    local files
    files=$(find . -maxdepth 1 -type f | fzf --multi)
    echo $files | xargs -I '{}' rm {} #we use xargs to capture filenames with spaces in them properly
  else
    command rm "$@"
  fi
}

function fzf-aliases-functions() {
  CMD=$(
    (
      (alias)
      (functions | grep "()" | cut -d ' ' -f1 | grep -v "^_")
    ) | fzf | cut -d '=' -f1
  )

  eval $CMD
}

function fzf-env-vars() {
  local out
  out=$(env | fzf)
  echo $(echo $out | cut -d= -f2)
}

function fzf-kill-processes() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

# [command-not-found](https://github.com/ohmyzsh/ohmyzsh/blob/master/plugins/command-not-found/command-not-found.plugin.zsh)
command-not-found() {
  local last_status=$?

  case $last_status in
  # 126: Permission denied (e.g., trying to run a directory)
  # 127: Command not found (e.g., typos like 'gti commit')
  126 | 127)
    hist -fs delete -1
    ;;
  *)
    # Do nothing for other codes, including 130 (Ctrl+C)
    ;;
  esac
}

add-zsh-hook precmd command-not-found
