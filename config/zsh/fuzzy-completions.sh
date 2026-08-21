# https://github.com/junegunn/fzf#custom-fuzzy-completion

# Custom fuzzy completion for "doge" command
#   e.g. doge **<TAB>
_fzf_complete_doge() {
  _fzf_complete --multi --reverse --prompt="doge> " -- "$@" < <(
    echo very
    echo wow
    echo such
    echo doge
  )
}

# ps -ef | fzf --bind 'ctrl-r:reload(ps -ef)' --header 'Press CTRL-R to reload' \
#   --header-lines=1 --layout=reverse
#
# find . -type f |
#   fzf --bind 'ctrl-d:reload(find . -type d),ctrl-f:reload(find . -type f)'
#
# FZF_DEFAULT_COMMAND='find . -type f' fzf \
#   --bind 'ctrl-d:reload(find . -type d),ctrl-f:reload($FZF_DEFAULT_COMMAND)'
#
# RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
# INITIAL_QUERY=""
# FZF_DEFAULT_COMMAND="$RG_PREFIX '$INITIAL_QUERY'" \
#   fzf --bind "change:reload:$RG_PREFIX {q} || true" \
#   --ansi --phony --query "$INITIAL_QUERY"

# function! RipgrepFzf(query, fullscreen)
#   let command_fmt = 'rg --column --line-number --no-heading --color=always --smart-case %s || true'
#   let initial_command = printf(command_fmt, shellescape(a:query))
#   let reload_command = printf(command_fmt, '{q}')
#   let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
#   call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
# endfunction
#
# command! -nargs=* -bang Rg call RipgrepFzf(<q-args>, <bang>0)
