export EDITOR=nvim
export DOTFILES="~/dotfiles/home"
path+=$HOME/.cargo/bin

# Aliases
alias ga="git add"
alias gb="git branch"
alias gca="git commit -a"
alias gcam="git commit -am"
alias gc="git commit"
alias gcm="git commit -m"
alias gd="git diff"
alias gds="git diff --staged"
alias glg="git log --all --oneline --graph --decorate"
alias gpl="git pull --prune"
alias gps="git push"
alias gs="git status -sb"
alias gm="git merge"
alias hx="helix"
alias ls="lsd"
alias l="ls -a"
alias lla="ls -la"
alias lt="ls --tree"
alias lg="lazygit"
alias cat="bat"
alias cd="z"
alias grep="rg"
alias c="clear"
alias du="dust"
alias find="fd"
alias v="nvim"
alias vi="nvim"
alias vim="nvim"
alias zshconf="nvim ~/.zshrc"
alias tmuxconf="nvim ~/.tmux.conf"
alias nvimconf="cd ~/.config/nvim/ && nvim"
alias hxconf="helix ~/.config/helix/config.toml"
alias tn="tmux new -s $(basename $PWD)"
alias home="cd ~"
alias pnpx="pnpm dlx"
alias pn="pnpm"

nvimone() {
	NVIM_APPNAME="nvimone" nvim
}
normvim() {
	NVIM_APPNAME="normvim" nvim
}

eval "$(starship init bash)"
eval "$(zoxide init bash)"
# eval "$(navi widget bash)"

#nvm
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"                   # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion" # This loads nvm bash_completion
#nvm
#
#
# pnpm
export PNPM_HOME="/home/artifex/.local/share/pnpm"
case ":$PATH:" in
*":$PNPM_HOME:"*) ;;
*) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
