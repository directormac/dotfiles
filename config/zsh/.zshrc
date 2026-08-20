
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

autoload -U compinit && compinit

# Sesh
# https://github.com/joshmedeski/sesh

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

function sesh-sessions() {
  {
    exec </dev/tty
    exec <&1
    local session
    session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
    zle reset-prompt > /dev/null 2>&1 || true
    [[ -z "$session" ]] && return
    sesh connect $session
  }
}

zle     -N             sesh-sessions
bindkey -M emacs '\es' sesh-sessions
bindkey -M vicmd '\es' sesh-sessions
bindkey -M viins '\es' sesh-sessions


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


source ~/.dotfiles/config/scripts/fzf-git.sh


export TZ="Asia/Manila"
export BROWSER="/usr/sbin/zen-browser" # set google chrome as default browser
export EDITOR=nvim # set neovim as default editor
export TERMINAL="/usr/sbin/ghostty"
export DOTFILES="$HOME/.dotfiles/" # dotfiles path
export PATH=$HOME/.cargo/bin:$PATH # cargo bins
export GPG_TTY=$(tty)
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

# Needed for tauri dev mode
export WEBKIT_DISABLE_COMPOSITING_MODE=1
export WEBKIT_DISABLE_DMABUF_RENDERER=1

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

eval "$(starship init zsh)"
eval "$(navi widget zsh)"
eval "$(fzf --zsh)"
eval "$(zoxide init --cmd cd zsh)"

# >>> mise:activate >>> managed by mise - do not edit between markers
eval "$(mise activate zsh)"
# <<< mise:activate <<<
