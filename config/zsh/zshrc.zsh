#!/usr/bin/env zsh

# [zsh](https://zsh.sourceforge.io/Doc/Release/zsh_toc.html)
# zmodload zsh/zprof

source "${DOTSZSH}/zinit.zsh"

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
