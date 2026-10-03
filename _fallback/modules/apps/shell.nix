{
  lib,
  self,
  ...
}:

{

  flake.homeModules.zsh = { pkgs, config, ... }: {

    xdg.configFile."fsh".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/fsh";

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = false;
      syntaxHighlighting.enable = false;
      history = {
        size = 100000;
        ignoreAllDups = true;
        path = "$HOME/.zsh_history";
        ignorePatterns = [
          "rm *"
          "pkill *"
          "cp *"
        ];
      };

      shellAliases = {
        "c" = "clear";
        "cat" = "bat";
        "cd" = "z";
        "cda" = "zoxide add";
        "cdq" = "zoxide query";
        "cdr" = "zoxide remove";
        "ci" = "zi";
        "dotfiles" = "cd ~/.dotfiles";
        "du" = "dust";
        "find" = "fd";
        "grep" = "rg";
        "age" = "rage";
        "l" = "lsd -a";
        "ll" = "lsd -l";
        "la" = "lsd -la";
        "ls" = "lsd";
        "lt" = "lsd --tree";
        "lzg" = "lazygit";
        "man" = "man -P bat -p";
        "nsh" = "nix-shell -p";
        "flakecheck" = "nix flake check ~/.dotfiles/_fallback";
        "nrsfc" = "sudo nixos-rebuild switch --flake .";
        "nrsf" = "sudo nixos-rebuild switch --flake ~/.dotfiles/_fallback";
        "nrbf" = "sudo nixos-rebuild boot --flake ~/.dotfiles/_fallback";
        "top" = "btop";
        "wh" = "which";
        "v" = "lazyvim";
        "spf" = "superfile";
        "vi" = "neovim";
        "nvim" = "lazyvim";
        "y" = "yazi";
        "zen" = "zen-beta";
        "wm" = "workmux";
        "tls" = "tmux ls";
        "ts" = "sesh last";
        "t" = "tv channels";
        "tn" = "sesh connect .";
        "logs" = "journalctl --user -f -n 50";
        "grab" = "ghgrab --cwd";
        "flake" = "nix flake";
        "nixdev" = "nix develop -c $SHELL";
        "oc" = "opencode";
        "wmd" = "workmux dashboard -t worktrees";
        "winbox" = "QT_QPA_PLATFORM=xcb WinBox | NUL";
      };

      sessionVariables = {
        EDITOR = "lazyvim";
        LS_COLORS = "$(vivid generate catppuccin-mocha)";
        BROWSER = "zen-beta";

        # https://stacker.news/items/948469
        NEWT_COLORS = "root=lavender,crust border=sapphire,base window=overlay0,base title=rosewater,crust button=surface2,lavender button_active=crust,maroon";
      };

      initContent =
        # sh
        ''
          autoload -Uz url-quote-magic
          zle -N self-insert url-quote-magic

          # Force double quotes around any video URL for MP3 conversion
          yt-mp3() {
              yt-dlp -x --audio-format mp3 "$1"
          }

          # Force double quotes around any video URL for FLAC conversion
          yt-flac() {
              yt-dlp -x --audio-format flac --audio-quality 0 "$1"
          }

          # Download playlist as sequential tracks wrapped in a folder
          yt-album() {
              yt-dlp -x --audio-format mp3 -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "$1"
          }

          # Absolute highest video quality combined as MKV
          yt-best() {
              yt-dlp -f bestvideo+bestaudio --merge-output-format mkv "$1"
          }

          # Download subtitles only without the underlying video stream
          yt-subs() {
              yt-dlp --write-subs --write-auto-subs --skip-download "$1"
          }

          zstyle ':fzf-tab:*' query-string ' '
          zstyle ':fzf-tab:*' use-fzf-default-opts yes
          zstyle ':completion:*:descriptions' format '[%d]'
          zstyle ':fzf-tab:*' fzf-pad 4
          zstyle ':fzf-tab:*' fzf-min-height 10
          zstyle ':fzf-tab:*' fzf-flags --height=~50%
          zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
          zstyle ':fzf-tab:*' switch-group '<' '>'
          zstyle ':fzf-tab:complete:_zlua:*' query-string input
          zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'lsd -la --color=always $realpath'
          zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -la --color=always $realpath'
          zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0


          eval "$(devenv hook zsh)"
          eval "$(zoxide init zsh)"

          function zvm_after_init() {
            zvm_bindkey viins '^R' fzf-history-widget
            zvm_bindkey vicmd '^R' fzf-history-widget

            # Television integration for zsh-vi-mode
            # zvm_bindkey viins '^I' tv-smart-autocomplete
            # zvm_bindkey viins '^T' tv-smart-autocomplete
            # zvm_bindkey viins '^R' tv-shell-history
            # zvm_bindkey vicmd '^R' tv-shell-history

            zvm_bindkey viins '^ ' autosuggest-accept
            zvm_bindkey viins '\e[27;5;9~' autosuggest-accept
            zvm_bindkey viins '^[[1;5I' autosuggest-accept     # Modern Ghostty sequence
            zvm_bindkey viins '\e[1;5I' autosuggest-accept     # Alternative Ghostty representation
          }

          bindkey '^ ' autosuggest-accept
          bindkey '\e[27;5;9~' autosuggest-accept
          bindkey '^[[27;5;9~' autosuggest-accept
          bindkey '^[[1;5I' autosuggest-accept
          bindkey '\e[1;5I' autosuggest-accept

          # Television integration for zsh-vi-mode
          # bindkey '^I' tv-smart-autocomplete
          # bindkey '^T' tv-smart-autocomplete
          # bindkey '^R' tv-shell-history
        '';

      plugins = [
        {
          name = "zsh-vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
        {
          name = "fzf-tab";
          src = pkgs.zsh-fzf-tab;
          file = "share/fzf-tab/fzf-tab.plugin.zsh";
        }
      ];

      fastSyntaxHighlighting = {
        enable = true;
        theme = "XDG:catppuccin-mocha";
      };

    };

    programs.carapace = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      environment = {
        CARAPACE_BRIDGES = "zsh,bash";
        CARAPACE_MATCH = true;
      };
      extraPackages = with pkgs; [
        carapace-bridge
      ];
    };

  };

  flake.nixosModules.zsh =
    {
      pkgs,
      config,
      ...
    }:
    {

      home-manager.users.${config.preferences.user.name} = {
        imports = [
          self.homeModules.zsh
        ];
      };

      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableBashCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = false;
        histSize = 100000;
      };
      users.defaultUserShell = pkgs.zsh;

      environment.systemPackages = with pkgs; [
        tree
        # https://github.com/zdharma-continuum/zinit#nixos
        # zinit
      ];

      environment.pathsToLink = [ "/share/zsh" ];
    };

}
