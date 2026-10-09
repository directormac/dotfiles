{
  lib,
  self,
  ...
}:

{

  flake.homeModules.zsh =
    { pkgs, config, ... }:
    let
      zsh-list-keys-tv = pkgs.writeShellScriptBin "zsh-list-keys-tv" ''
        ${pkgs.zsh}/bin/zsh -i -c '
          for km in viins vicmd visual; do
            bindkey -M "$km" 2>/dev/null | sed "s/^/$km /"
          done
        ' | ${pkgs.gawk}/bin/awk '
          BEGIN {
            # Descriptions for common widgets
            desc["autosuggest-accept"] = "Accept current autosuggestion"
            desc["fzf-history-widget"] = "Interactive command history search via fzf"
            desc["fzf-tab-complete"] = "Interactive fuzzy tab completion menu via fzf-tab"
            desc["tv-smart-autocomplete"] = "Smart path / command completion via television"
            desc["tv-shell-history"] = "Interactive shell history search via television"
            desc["tv-zsh-keys"] = "Fuzzy search zsh keybindings via television"
            desc["accept-line"] = "Execute the current command buffer"
            desc["clear-screen"] = "Clear terminal screen and redraw prompt"
            desc["vi-cmd-mode"] = "Switch to vi normal / command mode"
            desc["vi-insert"] = "Switch to vi insert mode"
            desc["vi-backward-delete-char"] = "Delete character before cursor (insert mode)"
            desc["vi-backward-kill-word"] = "Delete previous word (insert mode)"
            desc["vi-kill-line"] = "Kill entire command line buffer"
            desc["vi-forward-char"] = "Move cursor right one character"
            desc["vi-backward-char"] = "Move cursor left one character"
            desc["up-line-or-history"] = "Move cursor up or previous command in history"
            desc["down-line-or-history"] = "Move cursor down or next command in history"
            desc["self-insert"] = "Insert typed character into line buffer"
            desc["list-choices"] = "List completion choices"
            desc["list-expand"] = "Expand completion / word list"
            desc["bracketed-paste"] = "Handle terminal bracketed paste content"
            desc["undo"] = "Undo last edit"
            desc["redo"] = "Redo last undone edit"
            desc["vi-yank"] = "Yank (copy) text"
            desc["vi-delete"] = "Delete text into register"
            desc["vi-change"] = "Change (delete and enter insert mode)"
            desc["vi-put-after"] = "Paste buffer after cursor"
            desc["vi-put-before"] = "Paste buffer before cursor"
            desc["edit-command-line"] = "Open current command line in $EDITOR"
            desc["which-command"] = "Query which-command help for current command"
          }

          function decode_key(k,    clean, m) {
            clean = k
            gsub(/^"|"$/, "", clean)

            # Range: "^A"-"^C"
            if (match(clean, /^\^([A-Z])"-"\^([A-Z])$/, m)) return "Ctrl+" m[1] ".." m[2]
            if (match(clean, /^([a-zA-Z0-9])"-"([a-zA-Z0-9])$/, m)) return m[1] ".." m[2]
            if (clean == " \"-\"~\"" || clean == " -~") return "Printable Characters"

            # Specific special symbols
            if (clean == "^@") return "Ctrl+Space"
            if (clean == "^ ") return "Ctrl+Space"
            if (clean == "^I") return "Tab"
            if (clean == "^M" || clean == "^J") return "Enter"
            if (clean == "^?" || clean == "^H") return "Backspace"
            if (clean == "^[") return "Escape"

            # Modern terminal keys (CSI u / Ghostty / Kitty / XTerm)
            if (clean == "^[[1;5I" || clean == "\\e[1;5I") return "Ctrl+Tab (Ghostty)"
            if (clean == "^[[27;5;9~" || clean == "\\e[27;5;9~") return "Ctrl+Tab (CSI u)"
            if (clean == "^[[1;6I" || clean == "\\e[1;6I") return "Ctrl+Shift+Tab (Ghostty)"
            if (clean == "^[[27;6;9~" || clean == "\\e[27;6;9~") return "Ctrl+Shift+Tab (CSI u)"
            if (clean == "^[[Z" || clean == "\\e[Z") return "Shift+Tab"

            # Navigation / Cursor
            if (clean == "^[[A" || clean == "^[OA") return "Up"
            if (clean == "^[[B" || clean == "^[OB") return "Down"
            if (clean == "^[[C" || clean == "^[OC") return "Right"
            if (clean == "^[[D" || clean == "^[OD") return "Left"
            if (clean == "^[[H" || clean == "^[[1~") return "Home"
            if (clean == "^[[F" || clean == "^[[4~") return "End"
            if (clean == "^[[2~") return "Insert"
            if (clean == "^[[3~") return "Delete"
            if (clean == "^[[5~") return "PageUp"
            if (clean == "^[[6~") return "PageDown"

            # Chords
            if (match(clean, /^\^X\^([A-Z])$/, m)) return "Ctrl+X Ctrl+" m[1]
            if (match(clean, /^\^X(.)$/, m)) return "Ctrl+X " m[1]
            if (match(clean, /^\^\[([a-zA-Z0-9])$/, m)) return "Alt+" m[1]

            # Simple Control keys: ^A - ^Z
            if (match(clean, /^\^([A-Z])$/, m)) return "Ctrl+" m[1]

            return clean
          }

          {
            mode = $1
            line = $0
            sub(/^[^ ]+ +/, "", line)
            if (match(line, /^("[^"]*"(-"[^"]*")?) +(.*)$/, m)) {
              raw_key = m[1]
              widget = m[3]
            } else {
              match(line, /^([^ ]+) +(.*)$/, m)
              raw_key = m[1]
              widget = m[2]
            }

            if (length(raw_key) == 0 || length(widget) == 0) next

            human = decode_key(raw_key)
            d = (widget in desc) ? desc[widget] : "ZLE widget: " widget
            # Print tab-separated: Human, Widget, Mode, Raw, Description
            printf "%s\t%s\t%s\t%s\t%s\n", human, widget, mode, raw_key, d
          }
        '
      '';
    in
    {
      home.packages = [
        zsh-list-keys-tv
      ];

      # Television cable for zsh keybindings
      xdg.configFile."television/cable/zsh-keys.toml".text =
        # toml
        ''
          [metadata]
          name = "zsh-keys"
          description = "Fuzzy search zsh keybindings across viins, vicmd, and visual modes"
          requirements = ["zsh", "gawk"]

          [source]
          command = "${zsh-list-keys-tv}/bin/zsh-list-keys-tv"
          display = "{split:\t:0}  │  {split:\t:1}  [{split:\t:2}]"
          output = "{split:\t:1}"

          [preview]
          command = "echo -e '╭── Zsh Keybinding Details ───────────\n│ Key:         {split:\t:0}\n│ Mode / Map:  {split:\t:2}\n│ Raw Zsh:     {split:\t:3}\n╰──────────────────────────────────────\n\nWidget / Action:\n{split:\t:1}\n\nDescription:\n{split:\t:4}\n\nConfig Snippet (copy to shell.nix):\nzvm_bindkey {split:\t:2} {split:\t:3} {split:\t:1}'"

          [keybindings]
          enter = "actions:info"
          ctrl-y = "actions:copy_snippet"
          alt-y = "actions:copy_key"

          [actions.info]
          description = "Echo widget name"
          command = "echo '{split:\t:1}'"
          mode = "execute"

          [actions.copy_snippet]
          description = "Copy config snippet (zvm_bindkey ...) to clipboard"
          command = "echo -n \"zvm_bindkey {split:\t:2} {split:\t:3} {split:\t:1}\" | wl-copy"
          mode = "execute"

          [actions.copy_key]
          description = "Copy raw key to clipboard"
          command = "echo -n '{split:\t:3}' | wl-copy"
          mode = "execute"
        '';

      xdg.configFile."fsh".source =
        config.lib.file.mkOutOfStoreSymlink "${config.preferences.dotsConfigPath}/fsh";

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

        # completionInit =
        #   # sh
        #   ''
        #     autoload -U compinit && compinit
        #   '';

        shellAliases = {
          "agyx" = "agy  --dangerously-skip-permissions";
          "ocx" = "opencode --auto";
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
          "top" = "btop";
          "oc" = "opencode";
          "wh" = "which";
          "v" = "nvim";
          "vi" = "neovim";
          "nvim" = "lazyvim";
          "lazyvim" = "lazyvim";
          "y" = "yazi";
          "zen" = "zen-beta";
          "wm" = "workmux";
          "wmd" = "workmux dashboard -t worktrees";
          "wms" = "workmux sidebar";
          "wml" = "workmux list";
          "wmo" = "workmux open";
          "wma" = "workmux add";
          "wmq" = "workmux add --mode window --base main -l quickfix";
          "wmw" = "workmux add --mode window --base main -l agent-only";
          "wmm" = "workmux merge";
          "tls" = "tmux ls";
          "ts" = "sesh last";
          "todo" = "tuxedo";
          "t" = "tv --layout portrait --hide-preview --input-position bottom";
          "tvk" = "tv zsh-keys";
          "tn" = "sesh connect .";
          "logs" = "journalctl --user -f -n 50";
          "grab" = "ghgrab --cwd";
          "flake" = "nix flake";
          "nixdev" = "nix develop";
          "winbox" = "QT_QPA_PLATFORM=xcb WinBox | NUL";
        };

        sessionVariables = {
          EDITOR = "nvim";
          BROWSER = "zen-beta";
          # https://stacker.news/items/948469
          NEWT_COLORS = "root=lavender,crust border=sapphire,base window=overlay0,base title=rosewater,crust button=surface2,lavender button_active=crust,maroon";
        };

        initContent =
          # sh
          ''
            autoload -Uz url-quote-magic
            zle -N self-insert url-quote-magic

            # Force double quotes around any video URL for MP3 conversio
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

            spf() {
                os=$(uname -s)

                # Linux
                if [[ "$os" == "Linux" ]]; then
                    export SPF_LAST_DIR="${config.home.homeDirectory}/.local/state}/superfile/lastdir"
                fi

                # macOS
                if [[ "$os" == "Darwin" ]]; then
                    export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
                fi

                command spf "$@"

                [ ! -f "$SPF_LAST_DIR" ] || {
                    . "$SPF_LAST_DIR"
                    rm -f -- "$SPF_LAST_DIR" > /dev/null
                }
            }

            # Note: fzf does not support 'ctrl-tab' in --bind (unsupported key in fzf's Go core)
            # Enter accepts completion; Space types normal spaces in search query
            zstyle ':fzf-tab:*' use-fzf-default-opts yes
            zstyle ':completion:*:descriptions' format '[%d]'
            zstyle ':fzf-tab:*' fzf-pad 4
            zstyle ':fzf-tab:*' fzf-min-height 10
            zstyle ':fzf-tab:*' fzf-flags --height=~50%
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

              # -------------------------------------------------------------
              # Autosuggest Accept Keybindings (Ctrl+Tab only)
              # -------------------------------------------------------------
              # Ctrl+Tab (Modern terminal sequences)
              # zvm_bindkey viins '\e[27;5;9~' autosuggest-accept  # CSI u encoding
              # zvm_bindkey viins '^[[27;5;9~' autosuggest-accept # CSI u raw escape representation
              # zvm_bindkey viins '^[[1;5I' autosuggest-accept    # Ghostty / Kitty CSI format
              # zvm_bindkey viins '\e[1;5I' autosuggest-accept    # Alternative Ghostty representation
            }

            # -----------------------------------------------------------------
            # Global fallback keybindings (Ctrl+Tab only)
            # -----------------------------------------------------------------
            # Ctrl+Tab (Modern terminal sequences)
            # bindkey '\e[27;5;9~' autosuggest-accept              # CSI u encoding
            # bindkey '^[[27;5;9~' autosuggest-accept             # CSI u raw escape representation
            # bindkey '^[[1;5I' autosuggest-accept                 # Ghostty / Kitty CSI format
            # bindkey '\e[1;5I' autosuggest-accept                 # Alternative Ghostty representation

            # Television zsh keybinding search widget
            # tv-zsh-keys() {
            #   zle -I
            #   tv zsh-keys
            #   zle reset-prompt
            # }
            # zle -N tv-zsh-keys
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
