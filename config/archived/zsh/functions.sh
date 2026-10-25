# https://github.com/scaryrawr/fzf.zsh
# https://github.com/junegunn/fzf/blob/master/ADVANCED.md
# https://github.com/junegunn/fzf/wiki/Examples
# https://github.com/junegunn/fzf/wiki/Examples-(completion)

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

function rmr() {
  if [[ "$#" -eq 0 ]]; then
    local files

    # Run fd and pipe to fzf with an instructional header and custom prompt
    files=$(fd --hidden --no-ignore --strip-cwd-prefix --exclude .git -d 1 -t f | fzf --multi \
      --prompt="Delete> " \
      --header="[TAB] Select/Deselect | [ENTER] Confirm | [ESC] Cancel")

    # Check if files were selected (user didn't press ESC)
    if [[ -n "$files" ]]; then
      # Convert newlines to null bytes and pass to rm -v (verbose)
      echo "$files" | tr '\n' '\0' | xargs -0 rm -v
    else
      echo "Cancelled. No files deleted."
    fi
  else
    command rm "$@"
  fi
}

function xalias() {
  CMD=$(
    (
      (alias)
      (functions | grep "()" | cut -d ' ' -f1 | grep -v "^_")
    ) | fzf | cut -d '=' -f1
  )

  eval $CMD
}

function xvars() {
  local out
  out=$(env | fzf)
  echo $(echo $out | cut -d= -f2)
}

function find-proc() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')

  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

xkill() {
  local pid
  if [ "$UID" != "0" ]; then
    pid=$(ps -f -u $UID | sed 1d | fzf -m | awk '{print $2}')
  else
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  fi

  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

# _cache_eval() {
#   local name=$1
#   shift
#   local cache=~/.zsh/cache/$name.zsh
#   [[ -s $cache && $cache -nt ${commands[$1]:-/dev/null} ]] ||
#     {
#       mkdir -p ~/.zsh/cache
#       "$@" >$cache
#     }
#   source $cache
# }

# source ./fuzzy-completions.sh
# source ./fuzzy-functions.sh
