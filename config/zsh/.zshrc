
# History
HISTSIZE=120000
SAVEHIST=100000
HISTFILE=~/.zsh_history
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups


export TZ="Asia/Manila"
export BROWSER="/usr/sbin/zen-browser" # set google chrome as default browser
export EDITOR=nvim # set neovim as default editor
export TERMINAL="/usr/sbin/ghostty"
export DOTFILES="$HOME/.dotfiles/" # dotfiles path
export PATH=$HOME/.cargo/bin:$PATH # cargo bins
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

eval "$(starship init zsh)"

# >>> mise:activate >>> managed by mise - do not edit between markers
eval "$(mise activate zsh)"
# <<< mise:activate <<<
