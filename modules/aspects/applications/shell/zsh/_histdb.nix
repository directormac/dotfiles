# Zsh HistDB & Skim Integration
# Larkery's zsh-histdb (SQLite history tracker) + m42e's zsh-histdb-skim (Rust/Skim interactive finder)
{ config, pkgs }:
let
  histdbPkg = pkgs.local.zsh-histdb or pkgs.zsh-histdb;
  skimHistdbPkg = pkgs.local.zsh-skim-histdb or pkgs.zsh-skim-histdb;
in
{
  packages = [
    pkgs.sqlite
    skimHistdbPkg
    histdbPkg
  ];

  plugins = [
    {
      name = "zsh-histdb";
      file = "sqlite-history.zsh";
      src = "${histdbPkg}/share/zsh-histdb";
    }
    {
      name = "zsh-histdb-fzf";
      file = "histdb-fzf.zsh";
      src = "${histdbPkg}/share/zsh-histdb";
    }
    {
      name = "zsh-histdb-skim";
      file = "zsh-histdb-skim.plugin.zsh";
      src = "${skimHistdbPkg}/share/zsh-histdb-skim";
    }
  ];

  initContent =
    # zsh
    ''
      # zsh-histdb configuration
      export HISTDB_FILE="${config.home.homeDirectory}/.local/share/zsh/history.db"
      export HISTDB_DEFAULT_TAB="Everywhere"
      export HISTDB_PREVIEW="down:35%:wrap"
      export HISTDB_COLOR="fg:#cdd6f4,bg:default,matched:#cba6f7,matched_bg:default,current:#cdd6f4,current_bg:#313244,current_match:#f5c2e7,current_match_bg:#313244,info:#cba6f7,prompt:#cba6f7,cursor:#cba6f7,selected:#b4befe,header:#cba6f7,border:#6c7086,query:#cdd6f4"
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
    '';

  zvmKeybindings =
    # zsh
    ''
      # Primary: Interactive SQLite history search via zsh-histdb-skim (Catppuccin Mocha Mauve + bottom preview)
      zvm_bindkey viins '^R' histdb-skim-widget
      zvm_bindkey vicmd '^R' histdb-skim-widget

      # Television Slim history search via Ctrl+Shift+R
      zvm_bindkey viins '^[[27;6;114~' tv-history-slim-widget
      zvm_bindkey viins '^[[114;6u' tv-history-slim-widget
      zvm_bindkey viins '^[[82;6u' tv-history-slim-widget
      zvm_bindkey vicmd '^[[27;6;114~' tv-history-slim-widget
      zvm_bindkey vicmd '^[[114;6u' tv-history-slim-widget
      zvm_bindkey vicmd '^[[82;6u' tv-history-slim-widget

      # Fallback: Real FZF history search via Ctrl+Alt+R
      zvm_bindkey viins '^[^R' _fzf_histdb_widget
      zvm_bindkey vicmd '^[^R' _fzf_histdb_widget
    '';

  persistDirectories = [
    ".local/share/zsh"
    ".histdb"
  ];
}
