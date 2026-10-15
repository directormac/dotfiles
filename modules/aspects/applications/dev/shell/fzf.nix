# FZF Fuzzy Finder Aspect
{
  den.aspects.applications.dev.shell.fzf = {
    homeManager =
      { pkgs, ... }:
      {
        home.packages = [ pkgs.fzf ];

        programs.fzf = {
          enable = true;
          colors = { };
          enableBashIntegration = true;
          enableZshIntegration = true;
          tmux.enableShellIntegration = true;

          defaultOptions = [
            "--prompt='> '"
            "--marker='>'"
            "--pointer='◆'"
            "--scrollbar='│'"
            "--gutter=' '"
            "--preview-border='line'"
            "--border='none'"
            "--separator='─'"
            "--padding='1'"
            "--highlight-line"
            "--color=fg:#CDD6F4,fg+:#CDD6F4,bg:-1,bg+:-1"
            "--color=hl:#F38BA8,hl+:#F38BA8,info:#CBA6F7,marker:#B4BEFE"
            "--color=prompt:#CBA6F7,spinner:#F5E0DC,pointer:#CBA6F7,header:#F38BA8"
            "--color=border:#6C7086,label:#CDD6F4,query:#F5E0DC"
          ];

          changeDirWidget = {
            command = "fd --type d --strip-cwd-prefix --hidden --no-ignore --follow --exclude .git";
            options = [ ];
          };

          fileWidget = {
            command = "fd --type f --strip-cwd-prefix --hidden --no-ignore --follow --exclude .git";
            options = [ ];
          };

          historyWidget = {
            command = null;
            options = [
              "--layout=reverse"
              "--bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'"
              "--color header:italic"
              "--header 'Press CTRL-Y to copy command into clipboard'"
            ];
          };
        };
      };
  };
}
