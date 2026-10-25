#!/usr/bin/env zsh
# zmodload zsh/zprof

#=============================================================#
# .zshenv 	Contains exported environment variables
# .zprofile 	Contains environment variables and shell-specific options
# .zshrc 	Contains settings for interactive shell
# .zlogin 	Contains instructions to execute on session login
# .zlogout 	Contains instructions to execute on session logout
#=============================================================#

# [examples](https://zdharma-continuum.github.io/zinit/wiki/GALLERY/)
# [fresh](https://wicksipedia.com/blog/speeding-up-zsh-startup)
# [templates](https://github.com/black7375/BlaCk-Void-Zsh)
# [keybinds](https://sgeb.io/posts/zsh-zle-custom-widgets/)

#=============================================================#
# Zinit Installation Section
# [zinit](https://github.com/zdharma-continuum/zinit#manual)
# [wiki](https://zdharma-continuum.github.io/zinit/wiki/INTRODUCTION/)

# Plugins
# [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode)
# [fzf](https://github.com/junegunn/fzf#installation)
# [zsh-hist](https://github.com/marlonrichert/zsh-hist)
# [fzf-marks](https://github.com/urbainvaes/fzf-marks)
# [autosuggest-accept](https://github.com/zsh-users/zsh-autosuggestions#key-bindings)
# [zsh-history-substring-search](https://github.com/zsh-users/zsh-history-substring-search)
#
# [plugins](https://github.com/unixorn/awesome-zsh-plugins)

declare -A ZINIT
ZINIT[NO_ALIASES]=1

ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
[ ! -d $ZINIT_HOME ] && mkdir -p "$(dirname $ZINIT_HOME)"
[ ! -d $ZINIT_HOME/.git ] && git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
source "${ZINIT_HOME}/zinit.zsh"

autoload -Uz _zinit
((${+_comps})) && _comps[zinit]=_zinit

#=============================================================#

#=============================================================#
zlocal() {
  local module_path="$DOTFILES/config/$1"
  if [[ -f "$module_path" ]]; then
    source "$module_path"
  fi
}

turbo0() { zinit ice wait"0a" lucid "${@}"; }
turbo1() { zinit ice wait"0b" lucid "${@}"; }
turbo2() { zinit ice wait"0c" lucid "${@}"; }
zcommand() { zinit ice wait"0b" lucid as"command" "${@}"; }
zload() { zinit load "${@}"; }
zlight() { zinit light "${@}"; }
zsnippet() { zinit snippet "${@}"; }

# [zsh-clean-history](https://github.com/Automaat/zsh-clean-history)
# [zsh-hist](https://github.com/marlonrichert/zsh-hist)
# zstyle ':hist:*' auto-format yes
# zstyle ':hist:*' expand-aliases yes

# zstyle ':completion:*' menu no
zstyle ':completion:*:descriptions' format '[%d]'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zinit \
  depth"1" \
  light-mode \
  lucid for \
  cloneonly \
  nocompile \
  nocompletions \
  wait"0a" \
  zsh-users/zsh-completions \
  wait"0c" \
  zdharma-continuum/fast-syntax-highlighting \
  atload"_zsh_autosuggest_start;bindkey '^ ' autosuggest-accept" \
  wait"0c" \
  zsh-users/zsh-autosuggestions

# wait"0b" \
# hlissner/zsh-autopair \

# [fzf getting started](https://junegunn.github.io/fzf/getting-started/)
# [fzf reference](https://junegunn.github.io/fzf/reference/)
# [fzf shell-integration](https://junegunn.github.io/fzf/shell-integration/)
FZF_COMPLETION_TRIGGER='**'
FZF_COMPLETION_OPTS='--border --info=inline'
FZF_COMPLETION_PATH_OPTS='--walker file,dir,follow,hidden'
FZF_COMPLETION_DIR_OPTS='--walker dir,follow'

# [Generated](https://junegunn.github.io/fzf/color-themes/?s=XY8xDsIwEAS_Ei2tUxilckGTCgkqXuA4J_uUYFuWA0WUli_wP16CTCIkaGdud3UzMhRanWOcjGFfnYNxGgIGakZnobCTjWz2DRaBUGDUfc_eHn2cSlZCIMRcx8A-U4LC6_nY2FWn4YMOG7BTXm8qCDi2bmTr8ok9tY7MACUFupB6ShcayZR-HzxtaS6T9eqhMPLXxEQ3pvufWwTy7wtv)
export FZF_DEFAULT_OPTS=$'
  --prompt="> " 
  --marker=">" 
  --pointer="◆" 
  --scrollbar="│" 
  --gutter=" " 
  --preview-border="line"
  --border="none"
  --separator="─"
  --padding="1"
  --highlight-line
  --color=fg:#CDD6F4,fg+:#CDD6F4,bg:-1,bg+:-1
  --color=hl:#F38BA8,hl+:#F38BA8,info:#CBA6F7,marker:#B4BEFE
  --color=prompt:#CBA6F7,spinner:#F5E0DC,pointer:#CBA6F7,header:#F38BA8
  --color=border:#6C7086,label:#CDD6F4,query:#F5E0DC'

FZF_DEFAULT_FD_PARAMS="--strip-cwd-prefix --hidden --no-ignore --follow --exclude .git"
# FZF_DEFAULT_COMMAND="fd --type f $FZF_DEFAULT_FD_PARAMS"

FZF_ALT_C_COMMAND="fd --type d $FZF_DEFAULT_FD_PARAMS"
FZF_CTRL_T_COMMAND="fd --type f $FZF_DEFAULT_FD_PARAMS"

FZF_TAB_GROUP_COLORS=(
  $'\033[94m' $'\033[32m' $'\033[33m' $'\033[35m' $'\033[31m' $'\033[38;5;27m' $'\033[36m'
  $'\033[38;5;100m' $'\033[38;5;98m' $'\033[91m' $'\033[38;5;80m' $'\033[92m'
  $'\033[38;5;214m' $'\033[38;5;165m' $'\033[38;5;124m' $'\033[38;5;120m'
)
# [shell-key-bindings](https://github.com/junegunn/fzf/wiki/Configuring-shell-key-bindings)
FZF_CTRL_T_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'bat -n --color=always {}'
  --bind 'ctrl-/:change-preview-window(down|hidden|)'"

FZF_ALT_C_OPTS="
  --walker-skip .git,node_modules,target
  --preview 'tree -C {}'"

# FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window down:3:hidden:wrap --bind '?:toggle-preview'"

FZF_CTRL_R_OPTS="
  --layout=reverse
  --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
  --color header:italic
  --header 'Press CTRL-Y to copy command into clipboard'"

#[fzf-tab](https://github.com/Aloxaf/fzf-tab/wiki/Configuration)
# zstyle ":fzf-tab:*" fzf-command ftb-tmux-popup
# zstyle ':fzf-tab:*' prefix ''
# zstyle ':fzf-tab:*' single-group prefix color header
# zstyle ':fzf-tab:*' continuous-trigger 'ctrl-_'
# zstyle ':fzf-tab:*' switch-group 'alt-,' 'alt-.'
# zstyle ':fzf-tab:*' group-colors $FZF_TAB_GROUP_COLORS
# zstyle ':fzf-tab:*' popup-smart-tab no
# zstyle ':fzf-tab:*' accept-line enter
# zstyle ':fzf-tab:*' fzf-command fzf
# zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept

zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
zstyle ':fzf-tab:*' switch-group '<' '>'
zstyle ':fzf-tab:*' use-fzf-default-opts yes
zstyle ':fzf-tab:complete:_zlua:*' query-string input
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=always $realpath'
zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0

zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview \
  '[[ $group == "[process ID]" ]] && ps --pid=$word -o cmd --no-headers -w -w'
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags --preview-window=down:3:wrap
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' \
  fzf-preview 'echo ${(P)word}'
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview \
  'git diff $word | delta'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview \
  'git log --color=always $word'
zstyle ':fzf-tab:complete:git-help:*' fzf-preview \
  'git help $word | bat -plman --color=always'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview \
  'case "$group" in
	"commit tag") git show --color=always $word ;;
	*) git show --color=always $word | delta ;;
	esac'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview \
  'case "$group" in
	"modified file") git diff $word | delta ;;
	"recent commit object name") git show --color=always $word | delta ;;
	*) git log --color=always $word ;;
	esac'

zinit depth"1" has"fzf" wait"0a" lucid light-mode for \
  atinit'
    zicompinit
    zicdreplay
  ' \
  atload'
    source <(fzf --zsh)
  ' \
  Aloxaf/fzf-tab \
  urbainvaes/fzf-marks \
  src"fzf-git.sh" \
  junegunn/fzf-git.sh

# atload"bindkey '^g' fzm" \
# [keybind issue](https://github.com/junegunn/fzf-git.sh/issues/23#issuecomment-3368691708)
ZVM_OPEN_URL_CMD='firefox'
ZVM_OPEN_FILE_CMD='nvim'
ZVM_READKEY_ENGINE=zle
ZVM_KEYTIMEOUT=0.5
ZVM_CLIPBOARD_OSC52_TMUX=true
ZVM_SYSTEM_CLIPBOARD_ENABLED=true
ZVM_CLIPBOARD_OSC52_TMUX=true
# ZVM_LAZY_KEYBINDINGS=false
# [ZVM_INIT_DONE](https://github.com/jeffreytse/zsh-vi-mode/blob/master/zsh-vi-mode.zsh#L243)
# [zsh-vi-mode](https://github.com/jeffreytse/zsh-vi-mode#execute-extra-commands)
zvm_config() {
  ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
}

zinit light jeffreytse/zsh-vi-mode

ZSHFUNCTIONS=$DOTFILES/config/zsh
# zinit snippet "$ZSHFUNCTIONS/functions.sh"
# zinit snippet "$ZSHFUNCTIONS/fuzzy-functions.sh"

zlocal "/zsh/functions.sh"
zlocal "/zsh/fuzzy-functions.sh"
