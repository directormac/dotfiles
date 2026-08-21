# This is loaded universally for all types of shell sessions
# (interactive or non-interactive, login or non-login).
# It is the only configuration file that gets loaded for non-interactive
# and non-login scripts like cron jobs. However,
# macOS overrides this for PATH settings for interactive shells.
# This is universally loaded, so you could use it to configure the shell for automated processes like cron jobs.
# However, it is best to explicitly set up environmental variables for automated processes
# in scripts and leave nothing to chance. As a beginner,
# you will not use this configuration file. In fact, few experienced macOS developers use it.

export TZ="Asia/Manila"
export BROWSER="/usr/sbin/zen-browser" # set google chrome as default browser
export EDITOR="nvim"                   # set neovim as default editor
export TERMINAL="/usr/sbin/ghostty"
export DOTFILES="$HOME/.dotfiles/" # dotfiles path

export GPG_TTY=$(tty)
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

# [fzf](https://github.com/junegunn/fzf#setting-up-shell-integration)

# Use `` as the trigger sequence instead of the default **
export FZF_COMPLETION_TRIGGER='`'

# Options to fzf command
export FZF_COMPLETION_OPTS='--border --info=inline'

# Options for path completion (e.g. vim **<TAB>)
export FZF_COMPLETION_PATH_OPTS='--walker file,dir,follow,hidden'

# Options for directory completion (e.g. cd **<TAB>)
export FZF_COMPLETION_DIR_OPTS='--walker dir,follow'

# --color=fg:#CDD6F4,fg+:#CDD6F4,bg:#1E1E2E,bg+:#313244
export FZF_DEFAULT_OPTS=$FZF_DEFAULT_OPTS'
  --color=fg:#CDD6F4,fg+:#CDD6F4,bg:-1,bg+:-1
  --color=hl:#F38BA8,hl+:#F38BA8,info:#CBA6F7,marker:#B4BEFE
  --color=prompt:#CBA6F7,spinner:#F5E0DC,pointer:#CBA6F7,header:#F38BA8
  --color=border:#6C7086,label:#CDD6F4,query:#F5E0DC
  --border="none" --border-label="" --preview-window="border-sharp" --prompt="> "
  --marker=">" --pointer="◆" --separator="─" --scrollbar="│"'

export FZF_DEFAULT_FD_PARAMS="--strip-cwd-prefix --hidden --no-ignore --follow --exclude .git"

export FZF_DEFAULT_COMMAND="fd --type f $FZF_DEFAULT_FD_PARAMS"

export FZF_ALT_C_COMMAND="fd --type d $FZF_DEFAULT_FD_PARAMS"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# --bind 'ctrl-d:reload(find . -type d),ctrl-f:reload(eval "$FZF_DEFAULT_COMMAND")

export FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

export FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {}'"

#--bind 'ctrl-d:reload(find . -type d),ctrl-f:reload(eval "$FZF_DEFAULT_COMMAND")

export FZF_CTRL_R_OPTS="
  --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

export FZF_MARKS_FILE="${HOME}/.dotfiles/config/zsh/fzf-marks"
export FZF_MARKS_JUMP="^[m"

# Override the default open command
export ZVM_OPEN_CMD='xdg-open'
export KEYTIMEOUT=30

# Override the open command for URLs
export ZVM_OPEN_URL_CMD='firefox'
export ZVM_OPEN_FILE_CMD='nvim'
export ZVM_LAZY_KEYBINDINGS=false

# export FZF_MARKER_MAIN_KEY='\C-@'
# export FZF_MARKER_PLACEHOLDER_KEY='\C-v'

export FZF_CTRL_R_OPTS="
  --preview 'echo {}'
  --preview-window 'down:3:hidden:wrap'
  --bind 'ctrl-/:toggle-preview'
"

export LS_COLORS=':tw=01;34:ow=01;34:st=01;34'

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
# export DBUS_SESSION_BUS_ADDRESS
# export DBUS_SESSION_BUS_PID

export _ZO_EXCLUDE_DIRS="$HOME:$HOME/Resources/*:$HOME/Downloads/*:$HOME/Music:$HOME/Videos/*:$HOME/Downloads/*:$HOME/Pictures/*:$HOME/Documents/*:/tmp:/var:/proc:/sys:/deps:/_build:/node_modules/:/.git"

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

export ZVM_SYSTEM_CLIPBOARD_ENABLED=true
export ZVM_CLIPBOARD_OSC52_TMUX=true

export PATH=$HOME/.local/bin:$PATH

export PATH=$HOME/.cargo/bin:$PATH # cargo bins

typeset -U path PATH # auto-dedupe

path=(
  "$PATH"
  $path
)

export PATH
