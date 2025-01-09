{...}: {

  home.file."./.config/sway/" = {
    source = ../.config/sway;
    recursive = true;
  };

  home.file."./.config/sway/scripts/" = {
    source = ../.config/sway/scripts;
    recursive = true;
    executable = true;
  };

  home.file."~/.config/bat/" = {
    source = "~/.dotfiles/.config/bat";
    recursive = true;
  };
}
