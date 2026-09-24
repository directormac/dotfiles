{
  core.shell = {
    os = {
      programs.zsh = {
        enable = true;
        enableCompletion = true;
      };
    };

    nixos = { pkgs, ... }: {
      environment.enableAllTerminfo = true;
      users.defaultUserShell = pkgs.zsh;
      users.users.root.shell = pkgs.zsh;
    };
  };
}
