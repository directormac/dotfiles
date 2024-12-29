{ pkgs, ... }: {

  home.file.".tmux.conf".source = ./tmux.conf;

  programs = {

    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      baseIndex = 1;
      terminal = "tmux-256color";
      shell = "${pkgs.zsh}/bin/zsh";
    };
  };

}
