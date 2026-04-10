# Zinit

# Set the directory we want to store zinit and plugins
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

declare -A ZINIT
ZINIT[NO_ALIASES]=1

# Download Zinit, if it's not there yet
if [ ! -d "$ZINIT_HOME" ]; then
   mkdir -p "$(dirname $ZINIT_HOME)"
   git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

# Source/Load zinit
source "${ZINIT_HOME}/zinit.zsh"

# Add in zsh plugins
zinit light zsh-users/zsh-completions
zinit light marlonrichert/zsh-hist

# Snippets
zinit snippet OMZL::git.zsh
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::archlinux
zinit snippet OMZP::aws
zinit snippet OMZP::kubectl
zinit snippet OMZP::kubectx
zinit snippet OMZP::command-not-found

# Load completions before plugins that depend on them
autoload -Uz compinit && compinit
zinit cdreplay -q

zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting

zinit ice depth=1
zinit light jeffreytse/zsh-vi-mode

autoload -Uz add-zsh-hook

command-not-found () {
  local last_status=$?
  
  case $last_status in
    # 126: Permission denied (e.g., trying to run a directory)
    # 127: Command not found (e.g., typos like 'gti commit')
    126|127) 
      hist -fs delete -1
      ;;
    *)
      # Do nothing for other codes, including 130 (Ctrl+C)
      ;;
  esac
}

add-zsh-hook precmd command-not-found

# Keybindings
bindkey -e                               # Use Emacs-style keybindings (standard Zsh behavior)
bindkey '^p' history-search-backward     # Ctrl + P : Search history backward (based on what you've typed)
bindkey '^n' history-search-forward      # Ctrl + N : Search history forward (based on what you've typed)
bindkey '^[w' kill-region                # Alt  + W : Kill/Delete from cursor to the start of the word/region

# Smart Tab: Accept autosuggestion if it exists, otherwise do completion
# This combines zsh-autosuggestions and fzf-tab into one key
_smart_tab() {
  if [[ -n "$ZSH_AUTOSUGGEST_TEXT" ]]; then
    zle autosuggest-accept               # If there's a gray hint, Tab accepts it
  else
    zle expand-or-complete               # If no hint, Tab opens the completion menu (fzf-tab)
  fi
}
zle -N _smart_tab
bindkey '^I' _smart_tab                  # Tab (Ctrl + I is equivalent to Tab in terminals)

# Ensure zsh-vi-mode plays nice with other plugins
# This hook re-applies our Tab binding every time zsh-vi-mode initializes or changes modes
function zvm_after_init() {
  zvm_bindkey insert '^I' _smart_tab     # Keep Tab behavior active in Vi Insert Mode
}

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

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:*' use-fzf-default-opts yes

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# source ~/.secrets/secrets


# Exports
export TZ="Asia/Manila"
export BROWSER="/usr/sbin/zen-browser" # set google chrome as default browser
export EDITOR=nvim # set neovim as default editor
export TERMINAL="/usr/sbin/ghostty"
export DOTFILES="$HOME/.dotfiles/" # dotfiles path
export PATH=$HOME/.cargo/bin:$PATH # cargo bins
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

# Sesh function
function t() {
  local session
  if [[ -n "$1" ]]; then
    sesh connect "$1"
    return
  fi
  session=$(sesh list --icons | fzf --ansi --prompt='⚡  ' --border-label=' sesh ' --header='  ^a all ^t tmux ^g configs ^x zoxide ^d tmux <ctrl-c>...' \
      --bind 'tab:up,btab:down' \
      --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
      --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
      --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
      --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
      --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .git .)' \
      --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)')
  [[ -n "$session" ]] && sesh connect "$session"
}

# Sesh Keybind (Alt-s)
zle -N t
bindkey '\es' t

export OPENAI_KEY=
export GOPATH=$HOME/.go
export PATH="$HOME/.go/bin:$PATH"
export PATH="$HOME/.deno/bin:$PATH"
export PATH="$HOME/.moon/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export ANDROID_HOME="$HOME/.android"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$PATH"
export NDK_HOME="$ANDROID_HOME/ndk/27.2.12479018/"
# export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
export CAPACITOR_ANDROID_STUDIO_PATH=/usr/bin/android-studio
export PATH=$NDK_HOME:$PATH
export PATH=$HOME/.bun/bin:$PATH

# cargo install --locked launch-editor-nvim
export LAUNCH_EDITOR=launch-editor-nvim

# ASDF Exports
# . "/opt/asdf-vm/asdf.sh"
# export PATH="${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"
# . ~/.asdf/plugins/java/set-java-home.zsh

# FZF Exports

export _ZO_EXCLUDE_DIRS="$HOME:$HOME/Resources/*:$HOME/Downloads/*:$HOME/Music:$HOME/Videos/*:$HOME/Downloads/*:$HOME/Pictures/*:$HOME/Documents/*:/tmp:/var:/proc:/sys:/deps:/_build:/node_modules/:/.git"

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,gutter:-1,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

export FZF_DEFAULT_COMMAND="fd --hidden --no-ignore --strip-cwd-prefix --exclude .git"
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
export QT_QPA_PLATFORM=xcb
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_AUTO_SCREEN_SCALE_FACTOR=1
# export QT_QPA_PLATFORM=wayland-egl #error with apps xcb
#export QT_WAYLAND_FORCE_DPI=physical #uncomment this to use monitor's DPI
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

## Elementary environment
export ELM_DISPLAY=wl
export ECORE_EVAS_ENGINE=wayland_egl
export ELM_ENGINE=wayland_egl
export ELM_ACCEL=opengl
# export ELM_SCALE=1

export MISE_EXPERIMENTAL=1

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

function open_in_nvim(){
 nvim $(fzf --preview="bat {}")
}

function notes() {
  local session_name="notes"

  if tmux has-session -t "$session_name" 2>/dev/null; then
    echo "Attaching to existing tmux session '$session_name'..."
    tmux attach-session -t "$session_name"
  else
    tmux detach-client

    echo "Creating new tmux session '$session_name'..."
    tmux new-session -d -s "$session_name" -c "~/Notes"

    # You can add any commands you want to run in the new session here
    # For example, to open Vim:
    tmux send-keys -t "$session_name" "nvim" Enter

    tmux attach-session -t "$session_name"
  fi
}

alias notes='notes'


#Aliases
alias c="clear"
alias cat="bat"
alias clip="cliphist list | fzf --no-sort | cliphist decode | wl-copy"
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
# alias hx="helix"
alias hxconf="helix ~/.config/helix/config.toml"
alias inv='nvim $(fd --type=f --hidden | fzf -m --preview="bat --color=always {}")'
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
alias tn='sesh connect .'
alias top="btop" # top/htop alternative
alias tw="node_project" # works with alacritty + tmux
alias tweb="tmux_pnpm_node"  # works with alacritty + tmux
alias v="nvim"
alias vi="nvim"
alias wh="which"
alias y="yazi" 
alias zshconf="nvim ~/.zshrc"
alias in='sudo pacman -S' # install package
alias un='sudo pacman -Rns' # uninstall package
# alias up='sudo pacman -Syu' # update system/package/aur
alias pl='pacman -Qs' # list installed package
alias pa='pacman -Ss' # list availabe package
alias pc='sudo pacman -Sc' # remove unused cache
alias paclean='sudo pacman -Rns $(pacman -Qdtq)'
alias po='pacman -Qtdq | sudo pacman -Rns -' # remove unused packages, also try > pacman -Qqd | pacman -Rsu --print -
alias kubectl='minikube kubectl --'
alias mc="mcli"
alias dcd="docker-compose down"
alias dcu="docker-compose up -d"
alias ddcu="docker-compose -f docker/docker-compose.dev.yaml  up -d"
alias dcv="docker-compose down -v"

# alias mvim="NVIM_APPNAME=mac-nvim nvim"
alias mvim="NVIM_APPNAME=nvimmac nvim"
alias ws="windsurf"


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


alias oc="opencode"
alias zc="zeroclaw"

alias iex-phx="iex -S mix phx.server"

alias phxdev="iex --name phxdev@127.0.0.1 --cookie secret -S mix phx.server"

export HIP_PATH=/opt/rocm
export HIPCXX=/opt/rocm/bin/hipcc
export AMDGPU_TARGETS="gfx1101"
export GPU_TARGETS="gfx1101"

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
# alias cd="z"
# alias ci="zi"
# alias ca='zoxide add'
# alias cq='zoxide query'
# alias cr='zoxide remove'

up() {
  local d=""
  # If no argument is provided, default to 1 level up
  local limit=${1:-1}
  
  for i in {1..$limit}; do
    d+="../"
  done
  
  cd "$d"
}


alias pf="pitchfork"
alias pfui="pitchfork tui"

eval "$(starship init zsh)"
eval "$(navi widget zsh)"
eval "$(fzf --zsh)"
eval "$(mise activate zsh)"
# eval "$(zoxide init --cmd cd zsh)"

if [[ "$CLAUDECODE" != "1" ]]; then
    eval "$(zoxide init --cmd cd zsh)"
fi

# eval $(keychain --eval --quiet --gpg2 --agents ssh,gpg mac_mkra_dev markasena_gmail_com)

#Load secret API keys
if [ -f ~/.zsh_secrets ]; then
    source ~/.zsh_secrets
fi


# Vite+ bin (https://viteplus.dev)
. "$HOME/.vite-plus/env"

alias claude-mem='bun "/home/artifex/.claude/plugins/marketplaces/thedotmack/plugin/scripts/worker-service.cjs"'
