# Zsh HistDB & Skim Integration
# Larkery's zsh-histdb (SQLite history tracker) + m42e's zsh-histdb-skim (Rust/Skim interactive finder)
{ config, pkgs }:
let
  histdbPkg = pkgs.local.zsh-histdb or pkgs.zsh-histdb;
  skimHistdbPkg = pkgs.local.zsh-skim-histdb or pkgs.zsh-skim-histdb;
in
{
  initContent =
    # zsh
    ''
      # zsh-histdb configuration
      export HISTDB_FILE="${config.home.homeDirectory}/.local/share/zsh/history.db"
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
    '';

  packages = [
    pkgs.sqlite
    skimHistdbPkg
    histdbPkg
  ];

  persistDirectories = [
    ".local/share/zsh"
    ".histdb"
  ];

  plugins = [
    {
      file = "sqlite-history.zsh";
      name = "zsh-histdb";
      src = "${histdbPkg}/share/zsh-histdb";
    }
    {
      file = "histdb-fzf.zsh";
      name = "zsh-histdb-fzf";
      src = "${histdbPkg}/share/zsh-histdb";
    }
    {
      file = "zsh-histdb-skim.plugin.zsh";
      name = "zsh-histdb-skim";
      src = "${skimHistdbPkg}/share/zsh-histdb-skim";
    }
  ];

  zvmKeybindings =
    # zsh
    ''
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
    '';
}
