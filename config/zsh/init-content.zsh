source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/aliases.zsh"
source "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/functions.zsh"

# zsh-histdb configuration
export HISTDB_FILE="$HOME/.local/share/zsh/history.db"
export HISTDB_DEFAULT_TAB="Everywhere"
export HISTDB_PREVIEW="down:35%:wrap"
export HISTDB_COLOR="fg:#cdd6f4,bg:-1,matched:#cba6f7,matched_bg:-1,current:#cdd6f4,current_bg:#313244,current_match:#f5c2e7,current_match_bg:#313244,info:#cba6f7,prompt:#cba6f7,cursor:#cba6f7,selected:#b4befe,header:#cba6f7,border:#6c7086,query:#cdd6f4"
export HISTDB_TABULATE_CMD=(column -t -s $'\x1f')

# Exclude sensitive / noisy commands from histdb SQLite logging
export HISTORY_IGNORE="(rm *|pkill *|cp *|ls|cd|top|htop|clear|c)"

typeset -ga _BORING_COMMANDS
_BORING_COMMANDS=(
  "^ls$"
  "^cd$"
  "^ "
  "^histdb"
  "^top$"
  "^htop$"
  "^c$"
  "^clear$"
  "^rm "
  "^pkill "
  "^cp "
)

# zsh-autosuggestions integration with histdb
_zsh_autosuggest_strategy_histdb_top_here() {
  local query="select commands.argv from
  history left join commands on history.command_id = commands.rowid
  left join places on history.place_id = places.rowid
  where places.dir LIKE '$(sql_escape $PWD)%'
  and commands.argv LIKE '$(sql_escape $1)%'
  group by commands.argv order by count(*) desc limit 1"
  suggestion=$(_histdb_query "$query")
}

ZSH_AUTOSUGGEST_STRATEGY=(histdb_top_here history completion)

# Forgiving completion: case-insensitive matching everywhere
# (cd p now matches "projects" and "Projects")
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Include hidden files/dirs in all completions (cd, cat, vim, ...)
# and in interactive globs (echo *, ...)
setopt globdots

zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':fzf-tab:*' fzf-pad 4
zstyle ':fzf-tab:*' fzf-min-height 10
zstyle ':fzf-tab:*' fzf-flags --height=~50%
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' query-string ""
zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'
zstyle ':fzf-tab:complete:_zlua:*' query-string input
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'lsd -la --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -la --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0
zstyle ':fzf-tab:complete:(cat|bat):*' fzf-preview 'if [ -d $realpath ]; then lsd -la --color=always $realpath; else bat -pp --color=always $realpath 2>/dev/null || cat $realpath; fi'
zstyle ':fzf-tab:complete:(cat|bat):*' popup-pad 30 0

# zsh-vi-mode enhancements
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZVM_VI_EDITOR='nvim'
ZVM_ESCAPE_KEY_DELAY=0.01
ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
ZVM_CURSOR_STYLE_ENABLED=true

# Autosuggest Accept Keybindings (Ctrl+Y, Ctrl+Tab)
bindkey '^y' autosuggest-accept
bindkey '^[[27;5;9~' autosuggest-accept
bindkey '^[[1;5I' autosuggest-accept
bindkey '^[[9;5u' autosuggest-accept

# Autosuggest Execute Keybinding (Ctrl+Space)
bindkey '^ ' autosuggest-execute
bindkey '^@' autosuggest-execute
bindkey '^o' _fzf_super_search_widget
bindkey '^h' fzf-man-widget

function zvm_after_init() {
  # Primary: Interactive SQLite history search via fzf (histdb-fzf)
  zvm_bindkey viins '^R' _fzf_histdb_widget
  zvm_bindkey vicmd '^R' _fzf_histdb_widget

  # Secondary: Interactive SQLite history search via zsh-histdb-skim (Ctrl+Alt+R)
  zvm_bindkey viins '^[^R' histdb-skim-widget
  zvm_bindkey vicmd '^[^R' histdb-skim-widget

  # Tertiary: Television Slim history search via Ctrl+Shift+R
  zvm_bindkey viins '^[[27;6;114~' tv-history-slim-widget
  zvm_bindkey viins '^[[114;6u' tv-history-slim-widget
  zvm_bindkey viins '^[[82;6u' tv-history-slim-widget
  zvm_bindkey vicmd '^[[27;6;114~' tv-history-slim-widget
  zvm_bindkey vicmd '^[[114;6u' tv-history-slim-widget
  zvm_bindkey vicmd '^[[82;6u' tv-history-slim-widget

  # Autosuggest Accept Keybindings (Ctrl+Y, Ctrl+Tab)
  zvm_bindkey viins '^y' autosuggest-accept
  zvm_bindkey vicmd '^y' autosuggest-accept

  # Ghostty / raw CSI u Ctrl+Tab sequences
  zvm_bindkey viins '^[[27;5;9~' autosuggest-accept
  zvm_bindkey viins '^[[1;5I' autosuggest-accept
  zvm_bindkey viins '^[[9;5u' autosuggest-accept
  zvm_bindkey vicmd '^[[27;5;9~' autosuggest-accept
  zvm_bindkey vicmd '^[[1;5I' autosuggest-accept
  zvm_bindkey vicmd '^[[9;5u' autosuggest-accept

  # Autosuggest Execute Keybinding (Ctrl+Space in viins & vicmd)
  zvm_bindkey viins '^ ' autosuggest-execute
  zvm_bindkey viins '^@' autosuggest-execute
  zvm_bindkey vicmd '^ ' autosuggest-execute
  zvm_bindkey vicmd '^@' autosuggest-execute

  # Super search (Ctrl-O) and Man/TLDR (Ctrl-H)
  zvm_bindkey viins '^o' _fzf_super_search_widget
  zvm_bindkey vicmd '^o' _fzf_super_search_widget
  zvm_bindkey viins '^h' fzf-man-widget
  zvm_bindkey vicmd '^h' fzf-man-widget
}
