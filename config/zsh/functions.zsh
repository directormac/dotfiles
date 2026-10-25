
autoload -Uz bracketed-paste-url-magic
zle -N bracketed-paste bracketed-paste-url-magic

function up() {
  local d=""
  local limit=${1:-1}

  for i in {1..$limit}; do
    d+="../"
  done

  cd "$d"
}

function mkcd () {
  mkdir -p "$1" && cd "$1"
}


function dev-off() {
  # 1. Direnv & Devenv
  export SKIP_DIRENV=1
  typeset -g __DIRENV_INSTANT_ENV_FILE=""
  unset IN_NIX_SHELL name DEVENV_PROFILE DEVENV_ROOT DEVENV_STATE DEVENV_DOTFILE DEVENV_RUNTIME DEVENV_TASKS DEVENV_TASK_FILE DEVENV_FLAKE_SHELL PROFILER
  eval "$(cd /tmp && direnv export zsh 2>/dev/null)"

  # 2. Mise
  if (( $+commands[mise] )); then
    mise deactivate 2>/dev/null
  fi

  echo "Default shell active (devenv, direnv, mise disabled)"
}

alias pure-shell=dev-off
alias default-shell=dev-off
alias defshell=dev-off
alias direnv-off=dev-off

function dev-on() {
  # 1. Restore Direnv & Devenv
  unset SKIP_DIRENV
  if (( $+functions[_orig_direnv_hook] )); then
    _orig_direnv_hook
  fi
  direnv reload 2>/dev/null

  # 2. Restore Mise
  if (( $+commands[mise] )); then
    eval "$(command mise activate zsh 2>/dev/null)"
  fi

  echo "Dev shell active (devenv, direnv, mise re-enabled)"
}
alias dev-shell=dev-on
alias direnv-on=dev-on

# Intercept direnv / direnv-instant hook so SKIP_DIRENV=1 prevents background re-evaluation
if (( $+functions[_direnv_hook] )); then
  functions[_orig_direnv_hook]="$functions[_direnv_hook]"
  _direnv_hook() {
  if [[ "$SKIP_DIRENV" == "1" ]]; then
      return 0
  fi
  _orig_direnv_hook "$@"
  }
fi


function listening() {
lsof -i -n -P | grep --color=auto \
  --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} TCP |
  grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} LISTEN
}

function extract() {
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

function yt-mp3() {
  yt-dlp -x --audio-format mp3 "$1"
}

function yt-flac() {
  yt-dlp -x --audio-format flac --audio-quality 0 "$1"
}

function yt-album() {
  yt-dlp -x --audio-format mp3 -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "$1"
}

function yt-best() {
  yt-dlp -f bestvideo+bestaudio --merge-output-format mkv "$1"
}

function yt-subs() {
  yt-dlp --write-subs --write-auto-subs --skip-download "$1"
}

function y() {
  local tmp cwd; tmp="$(mktemp -t "yazi-cwd.XXXXXX")"
  command yazi "$@" --cwd-file="$tmp"
  IFS= read -r -d "" cwd < "$tmp"
  [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd" || builtin true
  command rm -f -- "$tmp"
}

function spf() {
  os=$(uname -s)

  if [[ "$os" == "Linux" ]]; then
    export SPF_LAST_DIR="$HOME/.local/state/superfile/lastdir"
  fi

  if [[ "$os" == "Darwin" ]]; then
    export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
  fi

  command superfile "$@"

  [ ! -f "$SPF_LAST_DIR" ] || {
    . "$SPF_LAST_DIR"
    rm -f -- "$SPF_LAST_DIR" > /dev/null
  }
}

function histdb-import-zsh() {
  local hist_src="${1:-$HOME/.zsh_history}"
  local db_dst="${HISTDB_FILE:-$HOME/.local/share/zsh/history.db}"

  if [[ ! -f "$hist_src" ]]; then
    echo "Error: History source file '$hist_src' not found."
    return 1
  fi

  echo "Importing '$hist_src' into '$db_dst'..."
  python3 -c '
  import sqlite3, os, re, sys

  hist_src = os.path.expanduser("'"$hist_src"'")
  db_dst = os.path.expanduser("'"$db_dst"'")

  entries = []
  current_entry = None

  with open(hist_src, "rb") as f:
    for line in f:
        line_str = line.decode("utf-8", errors="replace")
        m = re.match(r"^: ([0-9]+):([0-9]+);(.*)$", line_str)
        if m:
            if current_entry:
                entries.append(current_entry)
            ts, dur, cmd = m.groups()
            current_entry = (int(ts), int(dur), cmd)
        else:
            if current_entry is not None:
                current_entry = (current_entry[0], current_entry[1], current_entry[2] + line_str)
            else:
                entries.append((0, 0, line_str))

  if current_entry:
    entries.append(current_entry)

  conn = sqlite3.connect(db_dst)
  c = conn.cursor()

  c.execute("INSERT OR IGNORE INTO places (host, dir) VALUES (?, ?)", ("'"$HOST"'", "'"$HOME"'"))
  c.execute("SELECT id FROM places WHERE host = ? AND dir = ?", ("'"$HOST"'", "'"$HOME"'"))
  place_id = c.fetchone()[0]

  count = 0
  for ts, dur, cmd in entries:
    cmd = cmd.strip()
    if not cmd:
        continue
    c.execute("INSERT OR IGNORE INTO commands (argv) VALUES (?)", (cmd,))
    c.execute("SELECT id FROM commands WHERE argv = ?", (cmd,))
    cmd_id = c.fetchone()[0]
    c.execute(
        "INSERT INTO history (session, command_id, place_id, exit_status, start_time, duration) VALUES (?, ?, ?, ?, ?, ?)",
        (0, cmd_id, place_id, 0, ts or 1700000000, dur or 0)
    )
    count += 1

  conn.commit()
  conn.close()
  print(f"Successfully imported {count} commands into {db_dst}")
  '
}

function tv-history-slim-widget() {
  emulate -L zsh
  zle -I
  _disable_bracketed_paste 2>/dev/null

  local current_prompt="$LBUFFER"
  local output
  local hist_db="${HISTDB_FILE:-$HOME/.local/share/zsh/history.db}"

  if [[ -f "$hist_db" ]]; then
    output=$(sqlite3 -batch -noheader "$hist_db" "select distinct argv from commands order by id desc" | \
      tv --layout portrait --hide-preview --input-position top --input "$current_prompt" --inline)
  else
    output=$(history -n -1 0 | \
      tv --layout portrait --hide-preview --input-position top --input "$current_prompt" --inline)
  fi

  zle reset-prompt
  if [[ -n "$output" ]]; then
    RBUFFER=""
    LBUFFER="$output"
  fi
  _enable_bracketed_paste 2>/dev/null
}

function cat() {
  if [ $# -eq 0 ]; then
    command bat -pp
    return
  fi

  local all_md=1
  local has_file=0
  for arg in "$@"; do
    if [[ "$arg" =~ ^- ]]; then
      continue
    fi
    has_file=1
    if [[ "$arg" != *.md && "$arg" != *.markdown && "$arg" != *.MD && "$arg" != *.mdown && "$arg" != *.mdx ]]; then
      all_md=0
      break
    fi
  done

  # If all file arguments are markdown files and output is to terminal, use mdcat with pager
  if [ $has_file -eq 1 ] && [ $all_md -eq 1 ] && [ -t 1 ]; then
    mdcat -p "$@"
  else
    command bat -pp "$@"
  fi
}

# --- SSH Resilience & Port Forwarding ---
_ssh_disarm() {
  printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1004l\e[?1049l\e[?25h'
}

_ssh_interactive() {
  local value_opts="BbcDEeFIiJLlmOoPpQRSWw"
  local argv=("$@") arg letters i dest="" opts_done=""
  while (($#)); do
    arg="$1"
    shift
    if [[ -z $opts_done && $arg == "--" ]]; then
      opts_done=1
    elif [[ -z $opts_done && $arg == -?* ]]; then
      letters="${arg#-}"
      for ((i = 0; i < ${#letters}; i++)); do
        if [[ $value_opts == *"${letters:i:1}"* ]]; then
          (( i == ${#letters} - 1 )) && shift
          break
        fi
      done
    elif [[ -z $dest ]]; then
      dest="$arg"
    else
      return 1
    fi
  done
  [[ -n $dest ]] || return 1
  local resolved
  resolved=$(command ssh -G "${argv[@]}" 2>/dev/null) || return 1
  ! grep -i '^remotecommand ' <<<"$resolved" | grep -qvi '^remotecommand none$'
}

function ssh() {
  local rc started
  started=$SECONDS
  command ssh "$@"
  rc=$?
  [[ -t 1 ]] || return $rc
  _ssh_disarm
  if (( rc != 255 )) || [[ ! -t 0 ]] || ! _ssh_interactive "$@" || (( SECONDS - started < 30 )); then
    return $rc
  fi
  (
    while true; do
      echo "Connection lost. Reconnecting (Ctrl-C to stop)..."
      sleep 2
      command ssh "$@"
      rc=$?
      _ssh_disarm
      (( rc != 255 )) && exit $rc
    done
  )
  }

  function fip() {
  (( $# < 2 )) && echo "Usage: fip <host> <port1> [port2] ..." && return 1
  local host="$1"
  shift
  for port in "$@"; do
    command ssh -f -N -L "${port}:localhost:${port}" "$host" && echo "Forwarding localhost:$port -> $host:$port"
  done
}

function dip() {
  (( $# == 0 )) && echo "Usage: dip <port1> [port2] ..." && return 1
  for port in "$@"; do
    pkill -f "ssh.*-L ${port}:localhost:${port}" && echo "Stopped forwarding port $port" || echo "No forwarding on port $port"
  done
}

function lip() {
  pgrep -af "ssh.*-L [0-9]+:localhost:[0-9]+" || echo "No active forwards"
}

# --- Rsync Watchers ---
function rsw() {
  (( $# != 2 )) && echo "Usage: rsw <source> <destination>" && return 1
  local src="${1%/}" dest="$2"
  local sockets="${XDG_RUNTIME_DIR:-$HOME/.ssh/sockets}"
  mkdir -p "$sockets"
  local rsh="ssh -o ControlMaster=auto -o ControlPath=$sockets/rsw-%r@%h:%p -o ControlPersist=yes"
  setsid --fork env RSYNC_RSH="$rsh" bash -c 'rsync -a "$1/" "$2"; while inotifywait -r -q -e modify,create,delete,move "$1"; do rsync -a "$1/" "$2"; done' rsw-watch "$src" "$dest" >/dev/null 2>&1
  echo "Watching $src -> $dest"
}

function lsw() {
  local pid cmd rest found=0
  while read -r pid cmd; do
    rest="${cmd##*rsw-watch }"
    echo "$pid: ${rest% *} -> ${rest##* }"
    found=1
  done < <(pgrep -af 'rsw-watch ')
  (( found )) || echo "No active watches"
}

function dsw() {
  local pid found=0
  for pid in $(pgrep -f 'rsw-watch '); do
    kill -- -"$pid" 2>/dev/null && echo "Stopped watch (pid $pid)" && found=1
  done
  (( found )) || echo "No active watches"
}

# --- Fuzzy Process & Env Helpers ---
function xkill() {
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

function find-proc() {
  local pid
  pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
  if [ "x$pid" != "x" ]; then
    echo $pid | xargs kill -${1:-9}
  fi
}

function xalias() {
  local cmd
  cmd=$(
    (
      (alias)
      (functions | grep "()" | cut -d ' ' -f1 | grep -v "^_")
    ) | fzf | cut -d '=' -f1
  )
  [[ -n "$cmd" ]] && eval "$cmd"
}

function xvars() {
  local out
  out=$(env | fzf)
  [[ -n "$out" ]] && echo "${out#*=}"
}

# --- Dev Layout Automations for Tmux ---
function tdl() {
  [[ -z $1 ]] && { echo "Usage: tdl <c|cx|codex|other_ai> [<second_ai>]"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tdl."; return 1; }
  local current_dir="${PWD}"
  local editor_pane="$TMUX_PANE"
  local ai="$1" ai2="$2"
  tmux rename-window -t "$editor_pane" "$(basename "$current_dir")"
  tmux split-window -v -p 15 -t "$editor_pane" -c "$current_dir"
  local ai_pane=$(tmux split-window -h -p 30 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
  if [[ -n $ai2 ]]; then
    local ai2_pane=$(tmux split-window -v -t "$ai_pane" -c "$current_dir" -P -F '#{pane_id}')
    tmux send-keys -t "$ai2_pane" "$ai2" C-m
  fi
  tmux send-keys -t "$ai_pane" "$ai" C-m
  tmux send-keys -t "$editor_pane" "${EDITOR:-nvim} ." C-m
}

function tds() {
  [[ -z $TMUX ]] && { echo "Usage: tds"; return 1; }
  local current_dir="${PWD}"
  local editor_pane="$TMUX_PANE"
  tmux rename-window -t "$editor_pane" "$(basename "$current_dir")"
  local terminal_pane=$(tmux split-window -v -p 50 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
  local diff_pane=$(tmux split-window -h -p 50 -t "$editor_pane" -c "$current_dir" -P -F '#{pane_id}')
  local opencode_pane=$(tmux split-window -h -p 50 -t "$terminal_pane" -c "$current_dir" -P -F '#{pane_id}')
  tmux send-keys -t "$editor_pane" -l "${EDITOR:-nvim} ."
  tmux send-keys -t "$editor_pane" C-m
  tmux send-keys -t "$diff_pane" -l "git diff"
  tmux send-keys -t "$diff_pane" C-m
  tmux send-keys -t "$opencode_pane" -l "opencode"
  tmux send-keys -t "$opencode_pane" C-m
  tmux select-pane -t "$editor_pane"
}

function tsl() {
  [[ -z $1 || -z $2 ]] && { echo "Usage: tsl <pane_count> <command>"; return 1; }
  [[ -z $TMUX ]] && { echo "You must start tmux to use tsl."; return 1; }
  local count="$1" cmd="$2" current_dir="${PWD}"
  local -a panes
  tmux rename-window -t "$TMUX_PANE" "$(basename "$current_dir")"
  panes+=("$TMUX_PANE")
  while (( ${#panes[@]} < count )); do
    local new_pane=$(tmux split-window -h -t "${panes[-1]}" -c "$current_dir" -P -F '#{pane_id}')
    panes+=("$new_pane")
    tmux select-layout -t "${panes[0]}" tiled
  done
  for pane in "${panes[@]}"; do
    tmux send-keys -t "$pane" "$cmd" C-m
  done
  tmux select-pane -t "${panes[0]}"
}

# --- Fuzzy Widgets ---
function _fzf_super_search_widget() {
  local fd_cmd="fd --type f --hidden --exclude .git -0 | xargs -0 ls -t1d --color=always 2>/dev/null"
  local rg_cmd="rg --column --line-number --no-heading --color=always --smart-case"
  local rg_reload="[ -n {q} ] && $rg_cmd {q} || true"

  fzf --height 50% --popup 90%,70% \
    --layout reverse --multi --min-height 20+ \
    --no-separator --header-border horizontal \
    --border-label-pos 2 \
    --color 'label:blue' \
    --ansi --prompt 'Files> ' \
    --header 'CTRL-F: Files | CTRL-G: Grep | CTRL-U/D: Scroll | ENTER: Neovim' \
    --delimiter : \
    --bind "start:reload($fd_cmd)+unbind(change)" \
    --bind "change:reload(sleep 0.1; $rg_reload)" \
    --bind "ctrl-g:change-prompt(Grep> )+change-border-label( 🕵️ Grep )+disable-search+rebind(change)+reload($rg_reload)+clear-query" \
    --bind "ctrl-f:change-prompt(Files> )+change-border-label( 🥐 Files )+enable-search+unbind(change)+reload($fd_cmd)+clear-query" \
    --bind "ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down" \
    --bind "shift-up:preview-up,shift-down:preview-down" \
    --preview 'if [ "$FZF_PROMPT" = "Files> " ]; then
                   bat --color=always --style=numbers {1}
                 else
                   bat --color=always --style=numbers {1} --highlight-line {2}
                 fi' \
    --preview-window 'down,50%' --preview-border line \
    --bind 'ctrl-/:change-preview-window(down,50%|hidden|)' \
    --bind 'enter:become(if [ "$FZF_PROMPT" = "Files> " ]; then ${EDITOR:-nvim} {1}; else ${EDITOR:-nvim} {1} +{2}; fi)' \
    </dev/tty

  zle reset-prompt
}
zle -N _fzf_super_search_widget

function fzf-man-widget() {
  local manpage="echo {} | sed 's/\([[:alnum:][:punct:]]*\) (\([[:alnum:]]*\)).*/\2 \1/'"
  local batman="${manpage} | xargs -r man | col -bx | bat --language=man --plain --color always"
  man -k . 2>/dev/null | sort |
    awk -v cyan=$(tput setaf 6) -v blue=$(tput setaf 4) -v res=$(tput sgr0) -v bld=$(tput bold) '{ $1=cyan bld $1; $2=res blue $2; } 1' |
    fzf \
      -q "$1" \
      --ansi \
      --height 50% --popup 90%,70% \
      --tiebreak=begin \
      --prompt=' Man > ' \
      --preview-window '50%,rounded,<50(up,85%,border-bottom)' \
      --preview "${batman}" \
      --bind "enter:execute(${manpage} | xargs -r man)" \
      --bind "alt-c:+change-preview(curl -s cht.sh/{1})+change-prompt(ﯽ Cheat > )" \
      --bind "alt-m:+change-preview(${batman})+change-prompt( Man > )" \
      --bind "alt-t:+change-preview(tldr --color=always {1})+change-prompt(ﳁ TLDR > )"
  zle reset-prompt
}
zle -N fzf-man-widget

zle -N tv-history-slim-widget
# Transparently wrap pkexec for graphical applications in desktop sessions
pkexec() {
  if [[ -n "${DISPLAY:-}" || -n "${WAYLAND_DISPLAY:-}" ]] && [[ $# -gt 0 && "$1" != -* ]]; then
    if command -v pkexec-gui >/dev/null 2>&1; then
      command pkexec-gui "$@"
      return $?
    fi
  fi
  command pkexec "$@"
}
