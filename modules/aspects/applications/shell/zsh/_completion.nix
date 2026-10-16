# Zsh Completion & Syntax Highlighting Configuration
{
  completionInit =
    # sh
    ''
      eval "$(herdr completion zsh)"
      autoload -U compinit && compinit
    '';

  fzfTabZstyle =
    # zsh
    ''
      zstyle ':fzf-tab:*' use-fzf-default-opts yes
      zstyle ':completion:*:descriptions' format '[%d]'
      zstyle ':fzf-tab:*' fzf-pad 4
      zstyle ':fzf-tab:*' fzf-min-height 10
      zstyle ':fzf-tab:*' fzf-flags --height=~50%
      zstyle ':fzf-tab:*' switch-group '<' '>'
      zstyle ':fzf-tab:complete:_zlua:*' query-string input
      zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'lsd -la --color=always $realpath'
      zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -la --color=always $realpath'
      zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0
    '';

  fastSyntaxHighlighting = {
    enable = true;
    theme = "XDG:catppuccin-mocha";
  };
}
