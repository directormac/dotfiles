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
}
