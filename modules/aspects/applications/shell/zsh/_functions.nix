# Custom Interactive Shell Functions for Zsh
{ config }:
# sh
''
  autoload -Uz bracketed-paste-url-magic
  zle -N bracketed-paste bracketed-paste-url-magic

  function up() {
    local d=""
    local limit=''${1:-1}

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

  function spf() {
    os=$(uname -s)

    if [[ "$os" == "Linux" ]]; then
      export SPF_LAST_DIR="${config.home.homeDirectory}/.local/state/superfile/lastdir"
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
    local hist_src="''${1:-$HOME/.zsh_history}"
    local db_dst="''${HISTDB_FILE:-$HOME/.local/share/zsh/history.db}"

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
    local slim_config="''${XDG_CONFIG_HOME:-$HOME/.config}/television/tv-slim.toml"
    local hist_db="''${HISTDB_FILE:-$HOME/.local/share/zsh/history.db}"

    if [[ -f "$hist_db" ]]; then
      output=$(sqlite3 -batch -noheader "$hist_db" "select distinct argv from commands order by id desc" | \
        tv --config-file "$slim_config" --input "$current_prompt" --inline)
    else
      output=$(history -n -1 0 | \
        tv --config-file "$slim_config" --input "$current_prompt" --inline)
    fi

    zle reset-prompt
    if [[ -n "$output" ]]; then
      RBUFFER=""
      LBUFFER="$output"
    fi
    _enable_bracketed_paste 2>/dev/null
  }
  zle -N tv-history-slim-widget
''
