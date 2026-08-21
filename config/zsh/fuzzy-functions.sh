# https://github.com/scaryrawr/fzf.zsh
# https://github.com/junegunn/fzf/blob/master/ADVANCED.md
# https://github.com/junegunn/fzf/wiki/Examples
# https://github.com/junegunn/fzf/wiki/Examples-(completion)

fzf-history-widget-accept() {
  fzf-history-widget
  zle accept-line
}
zle -N fzf-history-widget-accept
bindkey '^X^R' fzf-history-widget-accept

function _fzf_super_search_widget() {

  # local fd_cmd="fd --type f --hidden --exclude .git --color=always"
  local fd_cmd="fd --type f --hidden --exclude .git -0 | xargs -0 ls -t1d --color=always 2>/dev/null"

  local rg_cmd="rg --column --line-number --no-heading --color=always --smart-case"

  local rg_reload="[ -n {q} ] && $rg_cmd {q} || true"

  fzf --height 50% --tmux 90%,70% \
    --layout reverse --multi --min-height 20+ \
    --no-separator --header-border horizontal \
    --border-label-pos 2 \
    --color 'label:blue' \
    --ansi --prompt 'Files> ' \
    --header 'CTRL-F: Files | CTRL-G: Grep | CTRL-U/D: Scroll | ENTER: Neovim' \
    --delimiter : \
    --bind "start:reload($fd_cmd)+unbind(change)" \
    --bind "change:reload(sleep 0.1; $rg_reload)" \
    --bind "ctrl-g:change-prompt(Grep> )+change-border-label( 🕵️ Grep )+disable-search+rebind(change)+reload($rg_reload)+clear-query" \
    --bind "ctrl-f:change-prompt(Files> )+change-border-label( 🥐 Files )+enable-search+unbind(change)+reload($fd_cmd)+clear-query" \
    --bind "ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down" \
    --bind "shift-up:preview-up,shift-down:preview-down" \
    --preview 'if [ "$FZF_PROMPT" = "Files> " ]; then
                   bat --color=always --style=numbers {1}
                 else
                   bat --color=always --style=numbers {1} --highlight-line {2}
                 fi' \
    --preview-window 'down,50%' --preview-border line \
    --bind 'ctrl-/:change-preview-window(down,50%|hidden|)' \
    --bind 'enter:become(if [ "$FZF_PROMPT" = "Files> " ]; then nvim {1}; else nvim {1} +{2}; fi)' \
    </dev/tty

  zle reset-prompt
}

zle -N _fzf_super_search_widget
bindkey '^o' _fzf_super_search_widget

fzf-man-widget() {
  manpage="echo {} | sed 's/\([[:alnum:][:punct:]]*\) (\([[:alnum:]]*\)).*/\2 \1/'"
  batman="${manpage} | xargs -r man | col -bx | bat --language=man --plain --color always --theme=\"Monokai Extended\""
  man -k . | sort |
    awk -v cyan=$(tput setaf 6) -v blue=$(tput setaf 4) -v res=$(tput sgr0) -v bld=$(tput bold) '{ $1=cyan bld $1; $2=res blue $2; } 1' |
    fzf \
      -q "$1" \
      --ansi \
      --tiebreak=begin \
      --prompt=' Man > ' \
      --preview-window '50%,rounded,<50(up,85%,border-bottom)' \
      --preview "${batman}" \
      --bind "enter:execute(${manpage} | xargs -r man)" \
      --bind "alt-c:+change-preview(cht.sh {1})+change-prompt(ﯽ Cheat > )" \
      --bind "alt-m:+change-preview(${batman})+change-prompt( Man > )" \
      --bind "alt-t:+change-preview(tldr --color=always {1})+change-prompt(ﳁ TLDR > )"
  zle reset-prompt
}
# `Ctrl-H` keybinding to launch the widget (this widget works only on zsh, don't know how to do it on bash and fish (additionaly pressing`ctrl-backspace` will trigger the widget to be executed too because both share the same keycode)
bindkey '^h' fzf-man-widget
zle -N fzf-man-widget
# Icon used is nerdfont

# Use fd and fzf to get the args to a command.
# Works only with zsh
# Examples:
# f mv # To move files. You can write the destination after selecting the files.
# f 'echo Selected:'
# f 'echo Selected music:' --extension mp3
# fm rm # To rm files in current directory
# f() {
#     sels=( "${(@f)$(fd "${fd_default[@]}" "${@:2}"| fzf)}" )
#     test -n "$sels" && print -z -- "$1 ${sels[@]:q:q}"
# }
#
# # Like f, but not recursive.
# fm() {
#   f "$@" --max-depth 1
# }
#
# # Deps
# alias fz="fzf-noempty --bind 'tab:toggle,shift-tab:toggle+beginning-of-line+kill-line,ctrl-j:toggle+beginning-of-line+kill-line,ctrl-t:top' --color=light -1 -m"
# fzf-noempty () {
# 	local in="$(</dev/stdin)"
# 	test -z "$in" && (
# 		exit 130
# 	) || {
# 		ec "$in" | fzf "$@"
# 	}
# }
# ec () {
# 	if [[ -n $ZSH_VERSION ]]
# 	then
# 		print -r -- "$@"
# 	else
# 		echo -E -- "$@"
# 	fi
# }
