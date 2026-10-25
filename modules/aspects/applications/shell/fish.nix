# Fish Shell Leaf Aspect
{
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

            # Autosuggestion Accept: Ctrl+Y, Ctrl+Tab
            bind -M insert \cy accept-autosuggestion
            bind -M default \cy accept-autosuggestion
            bind -M insert \e\[27\;5\;9~ accept-autosuggestion
            bind -M default \e\[27\;5\;9~ accept-autosuggestion

            # Autosuggestion Execute: Ctrl+Space
            bind -M insert ctrl-space 'commandline -f accept-autosuggestion execute'
            bind -M default ctrl-space 'commandline -f accept-autosuggestion execute'
            bind -M insert \c@ 'commandline -f accept-autosuggestion execute'
            bind -M default \c@ 'commandline -f accept-autosuggestion execute'
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
            "age" = "rage";
            "c" = "clear";
            "cat" = "bat -pp";
            "cd" = "z";
            "cda" = "zoxide add";
            "cdq" = "zoxide query";
            "cdr" = "zoxide remove";
            "ci" = "zi";
            "dotfiles" = "cd ~/.dotfiles";
            "du" = "dust";
            "find" = "fd";
            "flake" = "nix flake";
            "generations" = "tv nix-generations";
            "grab" = "ghgrab --cwd";
            "grep" = "rg";
            "hdb" = "histdb";
            "hdbs" = "histdb-sync";
            "hdbt" = "histdb-top";
            "l" = "lsd -a";
            "la" = "lsd -la";
            "less" = "bat";
            "ll" = "lsd -l";
            "logs" = "journalctl --user -f -n 50";
            "ls" = "lsd";
            "lt" = "lsd --tree";
            "lzd" = "lazydocker";
            "lzg" = "lazygit";
            "lzm" = "lazymark";
            "lzr" = "lazyrsync";
            "nhg" = "tv nix-generations";
            "nho" = "nh os";
            "nixdev" = "nix develop";
            "nsh" = "nix-shell -p";
            "oc" = "opencode";
            "oc2" = "opencode2";
            "ocx" = "opencode --auto";
            "pingcf" = "ping 1.1.1.1";
            "pinggg" = "ping google.com";
            "rebuild" = "rebuild-switch";
            "rmr" = "rm -r";
            "tls" = "tmux ls";
            "tn" = "sesh connect .";
            "todo" = "tuxedo";
            "top" = "btop";
            "ts" = "sesh last";
            "tv-inputs" = "tv flake-inputs";
            "tv-pkgs" = "tv update-pkgs";
            "tvk" = "tv zsh-keys";
            "vi" = "vim";
            "wh" = "which";
            "wm" = "workmux";
            "wma" = "workmux add";
            "wmd" = "workmux dashboard -t worktrees";
            "wml" = "workmux list";
            "wmm" = "workmux merge";
            "wmo" = "workmux open";
            "wmq" = "workmux add --mode window --base main -l quickfix";
            "wms" = "workmux sidebar";
            "wmw" = "workmux add --mode window --base main -l agent-only";
            "ytdl" = "yt-dlp";
            "ytdlm" = "yt-dlp --extract-audio --audio-format mp3";
            "zen" = "zen-beta";
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
