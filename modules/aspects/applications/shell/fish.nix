# Fish Shell Leaf Aspect
{
  core,
  den,
  ...
}:
{
  den.aspects.applications.shell.fish = {
    includes = [
      (den.batteries.user-shell "fish")
    ];

    homeManager =
      {
        pkgs,
        ...
      }:
      {
        programs.fish = {
          enable = true;

          interactiveShellInit = ''
            set -gx SHELL (command -v fish)

            function fish_prompt
                string join "" -- (set_color red) "[" (set_color yellow) $USER (set_color green) "@" (set_color blue) $hostname (set_color magenta) " " (prompt_pwd) (set_color red) ']' (set_color normal) "\$ "
            end

            set fish_greeting
            fish_vi_key_bindings

            # Bind Ctrl+Space to accept autosuggestion
            bind -M insert ctrl-space accept-autosuggestion
            bind -M default ctrl-space accept-autosuggestion

            set -gx FZF_COMPLETION_TRIGGER '**'
            set -gx FZF_COMPLETION_OPTS '--border --info=inline'
            set -gx FZF_COMPLETION_PATH_OPTS '--walker file,dir,follow,hidden'
            set -gx FZF_COMPLETION_DIR_OPTS '--walker dir,follow'
          '';

          plugins = [
            {
              name = "fzf";
              src = pkgs.fishPlugins.fzf.src;
            }
            {
              name = "fzf-fish";
              src = pkgs.fishPlugins.fzf-fish.src;
            }
          ];

          shellAliases = {
            "c" = "clear";
            "cat" = "bat -pp";
            "cd" = "z";
            "cda" = "zoxide add";
            "cdq" = "zoxide query";
            "cdr" = "zoxide remove";
            "ci" = "zi";
            "dotfiles" = "cd ~/.dotfiles";
            "find" = "fd";
            "grep" = "rg";
            "l" = "lsd -a";
            "less" = "bat";
            "ll" = "lsd -la";
          };
        };

        programs.zoxide = {
          enable = true;
          enableFishIntegration = true;
        };
      };

    persistHome.directories = [
      ".local/share/fish"
    ];
  };
}
