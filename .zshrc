# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# source ~/.secrets/secrets


# Exports
export TZ="Asia/Manila"
export BROWSER=firefox # set google chrome as default browser
export EDITOR=nvim # set neovim as default editor
export DOTFILES="$HOME/.dotfiles/" # dotfiles path
export PATH=$HOME/.cargo/bin:$PATH # cargo bins
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

export PATH=$HOME/.tmux/plugins/tmux-session-wizard/bin:$PATH
export OPENAI_KEY=
export GOPATH=$HOME/.go
export PATH="$HOME/.go/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
export PATH="$HOME/.moon/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
# export JAVA_HOME=/usr/lib/jvm/default/
# export JAVA_HOME=~/.asdf/plugins/java/set-java-home.zsh
export ANDROID_HOME="$HOME/.android"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
# export NDK_HOME="/opt/android-ndk"
# export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
export CAPACITOR_ANDROID_STUDIO_PATH=/usr/bin/android-studio
export PATH=$NDK_HOME:$PATH

# ASDF Exports
. "/opt/asdf-vm/asdf.sh"
. ~/.asdf/plugins/java/set-java-home.zsh

# FZF Exports

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

export FZF_DEFAULT_COMMAND="fd --hiden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

export LS_COLORS=':tw=01;34:ow=01;34:st=01;34'


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

source ~/.dotfiles/scripts/fzf-git.sh


# Needed for tauri dev mode
export WEBKIT_DISABLE_COMPOSITING_MODE=1
export WEBKIT_DISABLE_DMABUF_RENDERER=1

# Scripts
export PATH=$HOME/.dotfiles/scripts/:$PATH


## Setting environment variables for wayland session
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway
export XDG_CURRENT_SESSION=sway

## GTK environment
export TDESKTOP_DISABLE_GTK_INTEGRATION=1
export CLUTTER_BACKEND=wayland
export GDK_BACKEND="wayland,x11"
export NO_AT_BRIDGE=1
export WINIT_UNIX_BACKEND=wayland
export DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_PID

## Firefox
export MOZ_ENABLE_WAYLAND=1

## Qt environment
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_AUTO_SCREEN_SCALE_FACTOR=1
export QT_QPA_PLATFORM=wayland-egl #error with apps xcb
#export QT_WAYLAND_FORCE_DPI=physical #uncomment this to use monitor's DPI
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

## Elementary environment
export ELM_DISPLAY=wl
export ECORE_EVAS_ENGINE=wayland_egl
export ELM_ENGINE=wayland_egl
export ELM_ACCEL=opengl
# export ELM_SCALE=1

## SDL environment
export SDL_VIDEODRIVER=wayland

## Java environment
export _JAVA_AWT_WM_NONREPARENTING=1

# LibreOffice
export SAL_USE_VCLPLUGIN=gtk3

# Functions

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
alias less="moar"
alias la="ls -la"
alias ls="lsd"
alias lt="ls --tree"
alias lzd="lazydocker"
alias lzg="lazygit"
alias nvimconf="cd ~/.dotfiles/nvim/ && nvim"
alias pn="pnpm"
alias px="pnpm dlx"
alias rmr="rm -r"
alias ripgrep="rg"
alias tls="tmux ls" # tmux session list
alias tmuxconf="nvim ~/.tmux.conf"
alias td='tmux new-session -s $(basename "$PWD") -c "$PWD"'
alias tn='tmux new-session -s $(basename "$PWD") -c "$PWD"'
alias top="btop" # top/htop alternative
alias tw="node_project" # works with alacritty + tmux
alias tweb="tmux_pnpm_node"  # works with alacritty + tmux
alias v="nvim"
alias vi="nvim"
alias wh="which"
alias y="ya" 
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

alias mvim="NVIM_APPNAME=mac-nvim nvim"

# Arch Related
alias winbox="~/.dotfiles/WinBox & disown"

# Bun Aliases
alias bunx="bun x"
alias brun="bun --bun run dev"
alias bdev="bun --bun run dev"
alias bbuild="bun --bun run build"
alias bprewiew="bun --bun run preview"
alias btest="bun --bun run test"

alias b="bun run"

alias iex-phx="iex -S mix phx.server"

eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
eval "$(navi widget zsh)"
eval "$(fzf --zsh)"
# eval $(keychain --eval --quiet --gpg2 --agents ssh,gpg mac_mkra_dev markasena_gmail_com)


