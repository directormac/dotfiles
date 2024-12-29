{ pkgs, ... }: {
  home.packages = [ pkgs.gh pkgs.lazygit ];

  programs.git = {
    enable = true;

    ignores = [ ".direnv/" ];
    extraConfig = {
      init = { defaultBranch = "main"; };
      pull = { rebase = true; };
      push = { autoSetupRemote = true; };
      # merge = { conflictstyle = "diff3"; };
    };
  };

}
