#!/usr/bin/env zsh

# [zsh](https://zsh.sourceforge.io/Doc/Release/zsh_toc.html)
# zmodload zsh/zprof

# Loaded only for interactive shell sessions.
# It is loaded whenever you open a new terminal window or
# launch a subshell from a terminal window.

# [Reference](https://www.freecodecamp.org/news/how-do-zsh-configuration-files-work/)
# [Reference](https://mac.install.guide/terminal/configuration)

# [zinit](https://github.com/zdharma-continuum/zinit#manual)
# [wiki](https://zdharma-continuum.github.io/zinit/wiki/LS_COLORS-explanation/)
# [examples](https://zdharma-continuum.github.io/zinit/wiki/GALLERY/)
# [fresh](https://wicksipedia.com/blog/speeding-up-zsh-startup)
# [keybinds](https://sgeb.io/posts/zsh-zle-custom-widgets/)
#
# [templates](https://github.com/black7375/BlaCk-Void-Zsh)
# [plugins](https://github.com/unixorn/awesome-zsh-plugins)

# Zinit
# ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# [ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
# [ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"

source "${DOTSZSH}/zinit.zsh"
#
# autoload -Uz _zinit
# ((${+_comps})) && _comps[zinit]=_zinit
#
# https://github.com/zenobi-us/dotfiles
# zinit_load_local_module() {
#   local module_path="$DOTFILES/config/$1"
#   if [[ -f "$module_path" ]]; then
#     source "$module_path"
#   fi
# }
#
# zinit_load_local_module "zsh/functions.sh"

# Plugins
# [Loading Plugins](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/)
# [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode)
# [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)
# [fzf](https://github.com/junegunn/fzf#installation)
# [zsh-hist](https://github.com/marlonrichert/zsh-hist)
# [fzf-marks](https://github.com/urbainvaes/fzf-marks)

# zinit ice depth=1
# zinit ice depth=1
# zinit light jeffreytse/zsh-vi-mode

# Autosuggestions & fast-syntax-highlighting
# zinit wait lucid light-mode for \
#   atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay" \
#   zdharma-continuum/fast-syntax-highlighting \
#   atload"_zsh_autosuggest_start;" \
#   zsh-users/zsh-autosuggestions \
#   blockf atpull'zinit creinstall -q .' \
#   zsh-users/zsh-completions \
#   marlonrichert/zsh-hist
# atload!"bindkey '^g' fzm;" \

# zinit ice src"fzf-git.sh"
# zinit light junegunn/fzf-git.sh

# [ZVM_INIT_DONE](https://github.com/jeffreytse/zsh-vi-mode/blob/master/zsh-vi-mode.zsh#L243)
# [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode#execute-extra-commands)
# zinit wait'[[ $ZVM_INIT_DONE != "true" ]]' \
#   lucid light-mode for \
#   atload"bindkey '^G' fzm; unalias zi" \
#   urbainvaes/fzf-marks \
#   Aloxaf/fzf-tab \
#   chitoku-k/fzf-zsh-completions \
#   lincheney/fzf-tab-completion

# zinit ice wait'[[ $ZVM_INIT_DONE != "true" ]]' lucid light-mode for \
#   Aloxaf/fzf-tab
# chitoku-k/fzf-zsh-completions \
# lincheney/fzf-tab-completion

# function zvm_after_init() {
#
#   bindkey -r '^g'
#
#   bindkey '^ ' autosuggest-accept
#   bindkey -M viins '^M' accept-line
#
#   # zvm_bindkey vicmd '^I' ftb-fzf
#
#   eval "$(fzf --zsh)"
#
#   bindkey '^]' _navi_widget
# }

# # Smart Tab: Accept autosuggestion if it exists, otherwise do completion
# # This combines zsh-autosuggestions and fzf-tab into one key
# _smart_tab() {
#   if [[ -n "$ZSH_AUTOSUGGEST_TEXT" ]]; then
#     zle autosuggest-accept # If there's a gray hint, Tab accepts it
#   else
#     zle expand-or-complete # If no hint, Tab opens the completion menu (fzf-tab)
#   fi
# }
# zle -N _smart_tab
# bindkey '^I' _smart_tab # Tab (Ctrl + I is equivalent to Tab in terminals)
#
# # Ensure zsh-vi-mode plays nice with other plugins
# # This hook re-applies our Tab binding every time zsh-vi-mode initializes or changes modes
# # function zvm_after_lazy_keybindings() {
# #   zvm_bindkey vicmd '^I' _smart_tab
# # }

# source ~/.dotfiles/config/zsh/functions.sh
# source ~/.dotfiles/config/zsh/fuzzy-functions.sh

# #[fzf-tab-completion](https://github.com/lincheney/fzf-tab-completion#zsh)
# # only for git
# zstyle ':completion:*:*:git:*' fzf-search-display true
# # or for everything
# zstyle ':completion:*' fzf-search-display true
# # press ctrl-r to repeat completion *without* accepting i.e. reload the completion
# # press right to accept the completion and retrigger it
# # press alt-enter to accept the completion and run it
# keys=(
#   ctrl-r:'repeat-fzf-completion'
#   right:accept:'repeat-fzf-completion'
#   alt-enter:accept:'zle accept-line'
# )
# zstyle ':completion:*' fzf-completion-keybindings "${keys[@]}"
# # also accept and retrigger completion when pressing / when completing cd
# zstyle ':completion::*:cd:*' fzf-completion-keybindings "${keys[@]}" /:accept:'repeat-fzf-completion'
# zstyle ':completion:*' fzf-completion-secondary-color red
# zstyle ':completion::*:ls::*' fzf-completion-opts --preview='eval head {1}'
# zstyle ':completion::*:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-completion-opts --preview='eval eval echo {1}'
# zstyle ':completion::*:git::git,add,*' fzf-completion-opts --preview='git -c color.status=always status --short'
# zstyle ':completion::*:git::*,[a-z]*' fzf-completion-opts --preview='
# eval set -- {+1}
# for arg in "$@"; do
#     { git diff --color=always -- "$arg" | git log --color=always "$arg" } 2>/dev/null
# done'

# zstyle ':hist:*' auto-format yes
# zstyle ':hist:*' expand-aliases yes
#
# # [zsh-clean-history](https://github.com/Automaat/zsh-clean-history)
# #
# zstyle ':completion:*:git-checkout:*' sort false
# zstyle ':completion:*:descriptions' format '[%d]'
# zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
# zstyle ':completion:*' list-colors '${(s.:.)LS_COLORS}'
# zstyle ':completion:*' menu no
# zstyle ':fzf-tab:*' switch-group '<' '>'
# zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
# zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
# zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# zstyle ':fzf-tab:*' use-fzf-default-opts yes
# zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept

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

# add-zsh-hook precmd command-not-found

# Use fd (https://github.com/sharkdp/fd) for listing path candidates.
# - The first argument to the function ($1) is the base path to start traversal
# - See the source code (completion.{bash,zsh}) for the details.
_fzf_compgen_path() {
  fd --hidden --exclude .git . "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git . "$1"
}

# # # https://dev.to/martin_oehlert/from-14s-to-53ms-optimizing-zsh-startup-on-macos-5f09
# ZSH_COMP_CACHE="$HOME/.zsh-completion-cache"
# [[ -d "$ZSH_COMP_CACHE" ]] || mkdir -p "$ZSH_COMP_CACHE"
#
# _cache_fpath() {
#   local name="$1"
#   shift
#   local cache_file="$ZSH_COMP_CACHE/_$name"
#   local -a stale=($cache_file(N.mh+24))
#   if [[ ! -f "$cache_file" ]] || (($#stale)); then
#     "$@" >"$cache_file" 2>/dev/null
#   fi
# }
#
# fpath=($ZSH_COMP_CACHE $fpath)
#
# _cache_source() {
#   local name="$1"
#   shift
#   local cache_file="$ZSH_COMP_CACHE/$name.zsh"
#   local -a stale=($cache_file(N.mh+24))
#   if [[ ! -f "$cache_file" ]] || (($#stale)); then
#     "$@" >"$cache_file" 2>/dev/null
#     zcompile "$cache_file" 2>/dev/null
#   fi
#   source "$cache_file"
# }

# autoload -Uz compinit
# local -a zcompdump_stale=(~/.zcompdump(N.mh+24))
# if (($#zcompdump_stale)); then
#   compinit
# else
#   compinit -C
# fi
#
# { zcompile ~/.zcompdump; } &|

# History
HISTSIZE=120000
SAVEHIST=100000
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt append_history       # Use underscores; standard Zsh convention
setopt share_history        # Links sessions instantly
setopt hist_ignore_space    # Ignores commands starting with a space
setopt hist_ignore_all_dups # Keeps only the unique last copy of a duplicate command
setopt hist_save_no_dups    # Older duplicates are dropped when saving to file
setopt hist_find_no_dups    # Do not show duplicates when searching backwards
setopt hist_reduce_blanks

# Keybindings
# bindkey -e # Use Emacs-style keybindings (standard Zsh behavior)

# Open the current command in your $EDITOR (e.g., neovim)
# Press Ctrl+X followed by Ctrl+E to trigger
# autoload -Uz edit-command-line
# zle -N edit-command-line
# bindkey '^X^E' edit-command-line
# bindkey -M vicmd 'v' edit-command-line

# Press Ctrl+_ (Ctrl+Underscore) to undo
# This is built-in, no configuration needed!
# Redo widget exists but has no default binding:
# bindkey '^Y' redo  # Example binding if you want it

# Expands history expressions like !! or !$ when you press space
# bindkey ' ' magic-space

# Redirect stderr to /dev/null
alias -g NE='2>/dev/null'

# Redirect stdout to /dev/null
alias -g NO='>/dev/null'

# Redirect both stdout and stderr to /dev/null
alias -g NUL='>/dev/null 2>&1'

# Pipe to jq
alias -g J='| jq'

# Copy output to clipboard (macOS)
alias -g C='| wl-copy'

# zmv - Advanced Batch Rename/Move
#
# Enable zmv
# [zmd](https://github.com/zsh-users/zsh/blob/master/Functions/Misc/zmv)
autoload -Uz zmv

# Usage examples:
# zmv '(*).log' '$1.txt'           # Rename .log to .txt
# zmv -w '*.log' '*.txt'           # Same thing, simpler syntax
# zmv -n '(*).log' '$1.txt'        # Dry run (preview changes)
# zmv -i '(*).log' '$1.txt'        # Interactive mode (confirm each)

# Helpful aliases for zmv
alias zcp='zmv -C' # Copy with patterns
alias zln='zmv -L' # Link with patterns

# function copy-buffer-to-clipboard() {
#   echo -n "$BUFFER" | wl-copy
#   zle -M "Copied to clipboard"
# }
#
# zle -N copy-buffer-to-clipboard
# bindkey '^Xc' copy-buffer-to-clipboard

# unset **<TAB>
# export **<TAB>
# unalias **<TAB>

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# alias ffiles="v $(find . -type f | fzf)"
# alias fmove="mv $(fzf) $(fzf)"
# alias fword="vim $(rg . | fzf | cut -d ":" -f 1)"
# alias vi="nvim **"
# alias vi="vi $(fzf)"

# eval "$(navi widget zsh)"
# _cache_source navi navi widget zsh

eval "$(zoxide init zsh)"

eval "$(starship init zsh)"

# >>> mise:activate >>> managed by mise - do not edit between markers
eval "$(mise activate zsh)"
# <<< mise:activate <<<
