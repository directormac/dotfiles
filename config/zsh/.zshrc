# Loaded only for interactive shell sessions.
# It is loaded whenever you open a new terminal window or
# launch a subshell from a terminal window.
#
# [Reference](https://www.freecodecamp.org/news/how-do-zsh-configuration-files-work/)
# [Reference](https://mac.install.guide/terminal/configuration)

# Zinit
#
# [zinit](https://github.com/zdharma-continuum/zinit#manual)
# [examples](https://zdharma-continuum.github.io/zinit/wiki/GALLERY/)
# [keybinds](https://sgeb.io/posts/zsh-zle-custom-widgets/)
#
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

autoload -Uz _zinit
((${+_comps})) && _comps[zinit]=_zinit

zinit wait lucid light-mode for \
  atinit"ZINIT[COMPINIT_OPTS]=-C; zicompinit; zicdreplay" \
  zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start; unalias zi" \
  zsh-users/zsh-autosuggestions \
  blockf atpull'zinit creinstall -q .' \
  zsh-users/zsh-completions \
  atload"bindkey '^[[A' history-substring-search-up; bindkey '^[[B' history-substring-search-down" \
  zsh-users/zsh-history-substring-search \
  Aloxaf/fzf-tab

zinit load jeffreytse/zsh-vi-mode
zinit load marlonrichert/zsh-hist

# History
HISTSIZE=120000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt append_history       # Use underscores; standard Zsh convention
setopt share_history        # Links sessions instantly
setopt hist_ignore_space    # Ignores commands starting with a space
setopt hist_ignore_all_dups # Keeps only the unique last copy of a duplicate command
setopt hist_save_no_dups    # Older duplicates are dropped when saving to file
setopt hist_find_no_dups    # Do not show duplicates when searching backwards

_cache_eval() {
  local name=$1
  shift
  local cache=~/.zsh/cache/$name.zsh
  [[ -s $cache && $cache -nt ${commands[$1]:-/dev/null} ]] ||
    {
      mkdir -p ~/.zsh/cache
      "$@" >$cache
    }
  source $cache
}

# eval "$(navi widget zsh)"
_cache_eval navi navi widget zsh

eval "$(fzf --zsh)"
# _cache_eval fzf fzf --zsh

zvm_after_init() {
  # bindkey -r '^g'

  export KEYTIMEOUT=30

  # 1. Source fzf-git inside the safe zone so it registers its keys
  source ~/.dotfiles/config/zsh/fzf-git.sh

  # 2. Re-bind Navi
  bindkey '^]' _navi_widget
}

source ~/.dotfiles/config/zsh/fzf-helpers.sh

source ~/.dotfiles/config/zsh/functions.sh

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

eval "$(zoxide init zsh)"
# _cache_eval zoxide zoxide init zsh

eval "$(starship init zsh)"

# >>> mise:activate >>> managed by mise - do not edit between markers
eval "$(mise activate zsh)"
# <<< mise:activate <<<
