# Zsh Completion & Syntax Highlighting Configuration
{
  completionInit =
    # sh
    ''
      eval "$(herdr completion zsh)"
      autoload -U compinit && compinit
    '';

  fastSyntaxHighlighting = {
    enable = true;
    theme = "XDG:catppuccin-mocha";
  };

  fzfTabZstyle =
    # zsh
    ''
      # Forgiving completion: case-insensitive matching everywhere
      # (cd p now matches "projects" and "Projects")
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

      # Include hidden files/dirs in all completions (cd, cat, vim, ...)
      # and in interactive globs (echo *, ...)
      setopt globdots

      zstyle ':fzf-tab:*' use-fzf-default-opts yes
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':fzf-tab:*' fzf-pad 4
      zstyle ':fzf-tab:*' fzf-min-height 10
      zstyle ':fzf-tab:*' fzf-flags --height=~50%
      zstyle ':fzf-tab:*' switch-group '<' '>'
      zstyle ':fzf-tab:*' query-string ""
      zstyle ':fzf-tab:*' fzf-bindings 'tab:accept'
      zstyle ':fzf-tab:complete:_zlua:*' query-string input
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'lsd -la --color=always $realpath'
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -la --color=always $realpath'
      zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0
      zstyle ':fzf-tab:complete:(cat|bat):*' fzf-preview 'if [ -d $realpath ]; then lsd -la --color=always $realpath; else bat -pp --color=always $realpath 2>/dev/null || cat $realpath; fi'
      zstyle ':fzf-tab:complete:(cat|bat):*' popup-pad 30 0
    '';
}
