# FZF Fuzzy Finder Aspect
{
  den.aspects.applications.dev.shell.fzf = {
    homeManager =
      {
        config,
        lib,
        pkgs,
        ...
      }:
      {
        home.packages = [ pkgs.fzf ];

        programs.fzf = {
          changeDirWidget = {
            options = [ ];
            command = "fd --type d --strip-cwd-prefix --hidden --no-ignore --follow --exclude .git";
          };

          colors = with config.lib.stylix.colors.withHashtag; {
            bg = lib.mkForce "-1";
            "bg+" = lib.mkForce "-1";
            border = lib.mkDefault base03;
            fg = lib.mkForce base05;
            "fg+" = lib.mkForce base05;
            gutter = lib.mkDefault "-1";
            header = lib.mkForce base08;
            hl = lib.mkForce base08;
            "hl+" = lib.mkForce base08;
            info = lib.mkForce base0E;
            label = lib.mkDefault base05;
            marker = lib.mkForce base07;
            pointer = lib.mkForce base0E;
            prompt = lib.mkForce base0E;
            query = lib.mkDefault base06;
            spinner = lib.mkForce base06;
          };

          defaultOptions = [
            "--layout=reverse"
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
          ];

          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;

          fileWidget = {
            options = [ ];
            command = "fd --type f --strip-cwd-prefix --hidden --no-ignore --follow --exclude .git";
          };

          historyWidget = {
            options = [
              "--layout=reverse"
              "--bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'"
              "--color header:italic"
              "--header 'Press CTRL-Y to copy command into clipboard'"
            ];

            command = null;
          };

          tmux.enableShellIntegration = true;
        };

        stylix.targets.fzf.enable = lib.mkDefault true;
      };
  };
}
