# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Exports
export TZ="Asia/Manila"
export BROWSER=firefox-developer-edition # set google chrome as default browser
export EDITOR=nvim # set neovim as default editor
export DOTFILES="$HOME/.dotfiles/" # dotfiles path
# export PATH=$HOME/.cargo/bin:$PATH # cargo bins

export TMUXIFIER_LAYOUT_PATH="$HOME/.tmux/layouts/"
export OPENAI_KEY=
export GOPATH=$HOME/.go
export PATH="$HOME/.go/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"

export JAVA_HOME=/usr/lib/jvm/default/
export ANDROID_HOME="$HOME/.android/sdk"
export PATH=$ANDROID_HOME/emulator:$ANDROID_HOME/tools:$ANDROID_HOME/tools/bin:$ANDROID_HOME/platform-tools:$PATH
export NDK_HOME="/opt/android-ndk"
export PATH=$NDK_HOME:$PATH

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# export FZF_DEFAULT_OPTS=" \
# --color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
# --color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
# --color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# Scripts
export PATH=$HOME/.config/artifex/scripts/:$PATH


[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "marlonrichert/zsh-autocomplete"
plug "hlissner/zsh-autopair"
plug "wintermi/zsh-rust"
plug "zap-zsh/nvm"
plug "zap-zsh/fzf"
plug "zap-zsh/web-search"
plug "MichaelAquilina/zsh-autoswitch-virtualenv"

# Load and initialise completion system
autoload -Uz compinit
compinit

source ~/.config/wezterm/zsh_completions


function node_project {
  tmux . && tmuxifier w web
}


function tmux_pnpm_node {
  SESSION_NAME=$(pwd | sed 's/.*\///g')
  tmux new -s $SESSION_NAME -n code -d
  tmux send-keys -t $SESSION_NAME 'nvim' C-m
  tmux new-window -n commands -t $SESSION_NAME
  tmux split-window -h -t $SESSION_NAME:2
  tmux send-keys -t $SESSION_NAME:2.right 'pnpm install && pnpm dev' C-m
  tmux send-keys -t $SESSION_NAME:2.left 'git init' C-m
  tmux new-window -n run -t $SESSION_NAME
  tmux select-window -t $SESSION_NAME:1
  tmux attach -t $SESSION_NAME
}

function ya() {
    tmp="$(mktemp -t "yazi-cwd.XXXXX")"
    yazi --cwd-file="$tmp"
    if cwd="$(cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
        cd -- "$cwd"
    fi
    rm -f -- "$tmp"
}


# git repository greeter
# last_repository=
# check_directory_for_new_repository() {
# 	current_repository=$(git rev-parse --show-toplevel 2> /dev/null)
#
# 	if [ "$current_repository" ] && \
# 	   [ "$current_repository" != "$last_repository" ]; then
# 		onefetch --image $HOME/.dotfiles/avatar.jpg
# 	fi
# 	last_repository=$current_repository
# }
# cd() {
# 	builtin cd "$@"
# 	check_directory_for_new_repository
# }
#
# check_directory_for_new_repository
# optional, greet also when opening shell directly in repository directory
# adds time to startup


# alias  l='eza -l  --icons'
# alias ls='eza -1  --icons'
# alias ll='eza -la --icons'
# alias ld='eza -lD --icons'
#

#Aliases
alias c="clear"
alias cat="bat"
alias cd="z"
alias ci="zi"
alias du="dust"
alias find="fd"
alias ga="git add"
alias gb="git branch"
alias gc="git commit"
alias gca="git commit -a"
alias gcam="git commit -am"
alias gcm="git commit -m"
alias gd="git diff"
alias gds="git diff --staged"
alias glg="git log --all --oneline --graph --decorate"
alias gm="git merge"
alias gpl="git pull --prune"
alias gps="git push"
alias gpom="git push"
alias gpt="tgpt"
alias grep="rg"
alias gs="git status -sb"
alias home="cd ~"
alias hx="helix"
alias hxconf="helix ~/.config/helix/config.toml"
alias l="ls -a"
alias la="ls -la"
alias ls="lsd"
alias lt="ls --tree"
alias lzd="lazydocker"
alias lzg="lazygit"
alias nvimconf="cd ~/.dotfiles/nvim/ && nvim"
alias pn="pnpm"
alias px="pnpm dlx"
alias ripgrep="rg"
alias td="tmux new -s $(pwd | sed 's/.*\///g')"
alias tls="tmux ls" # tmux session list
alias tmuxconf="nvim ~/.tmux.conf"
alias tn="tmux $(basename $PWD)" # Create new tmux session on current directory
alias top="btop" # top/htop alternative
alias tw="node_project" # works with alacritty + tmux
alias tweb="tmux_pnpm_node"  # works with alacritty + tmux
alias tx="tmuxifier"
alias v="nvim"
alias vi="nvim"
alias wh="which"
alias y="ya" # exit yazi with cwd
alias zshconf="nvim ~/.zshrc"
alias in='sudo pacman -S' # install package
alias un='sudo pacman -Rns' # uninstall package
alias up='sudo pacman -Syu' # update system/package/aur
alias pl='pacman -Qs' # list installed package
alias pa='pacman -Ss' # list availabe package
alias pc='sudo pacman -Sc' # remove unused cache
alias po='pacman -Qtdq | sudo pacman -Rns -' # remove unused packages, also try > pacman -Qqd | pacman -Rsu --print -
alias kubectl='minikube kubectl --'
alias mc="mcli"
alias dcd="docker-compose down"
alias dcu="docker-compose up -d"


# Arch Related
# alias winbox="wine start /unix $HOME/.dotfiles/winbox64.exe"

# Bun Aliases
alias bunx="bun x"
alias brun="bun --bun run dev"
alias bdev="bun --bun run dev"
alias bbuild="bun --bun run build"
alias bprewiew="bun --bun run preview"
alias btest="bun --bun run test"



eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(navi widget zsh)"

#nvm
source /usr/share/nvm/init-nvm.sh
#nvm

. "$HOME/.asdf/asdf.sh"

# pnpm
export PNPM_HOME="/home/artifex/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export LS_COLORS=':tw=01;34:ow=01;34:st=01;34'

# opam configuration
# [[ ! -r /home/artifex/.opam/opam-init/init.zsh ]] || source /home/artifex/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null



# Add JBang to environment
alias j!=jbang
export PATH="$HOME/.jbang/bin:$PATH"
