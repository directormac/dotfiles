# Zsh Interactive Shell Leaf Aspect
{
  den.aspects.applications.shell.zsh = {
    nixos =
      { lib, pkgs, ... }:
      {
        environment.pathsToLink = [ "/share/zsh" ];

        environment.systemPackages = with pkgs; [
          tree
        ];

        programs.zsh = {
          autosuggestions.enable = false;
          enable = lib.mkDefault true;
          enableBashCompletion = true;
          enableCompletion = true;
          histSize = 100000;
          syntaxHighlighting.enable = false;
        };

        users.defaultUserShell = pkgs.zsh;
      };

    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";

        zsh-list-keys-tv = pkgs.writeShellScriptBin "zsh-list-keys-tv" ''
          ${pkgs.zsh}/bin/zsh -i -c '
            for km in viins vicmd visual; do
              bindkey -M "$km" 2>/dev/null | sed "s/^/$km /"
            done
          ' | ${pkgs.gawk}/bin/awk '
            BEGIN {
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

              if (match(clean, /^\^([A-Z])"-"\^([A-Z])$/, m)) return "Ctrl+" m[1] ".." m[2]
              if (match(clean, /^([a-zA-Z0-9])"-"([a-zA-Z0-9])$/, m)) return m[1] ".." m[2]
              if (clean == " \"-\"~\"" || clean == " -~") return "Printable Characters"

              if (clean == "^@") return "Ctrl+Space"
              if (clean == "^ ") return "Ctrl+Space"
              if (clean == "^I") return "Tab"
              if (clean == "^M" || clean == "^J") return "Enter"
              if (clean == "^?" || clean == "^H") return "Backspace"
              if (clean == "^[") return "Escape"

              if (clean == "^[[1;5I" || clean == "\\e[1;5I") return "Ctrl+Tab (Ghostty)"
              if (clean == "^[[27;5;9~" || clean == "\\e[27;5;9~") return "Ctrl+Tab (CSI u)"
              if (clean == "^[[1;6I" || clean == "\\e[1;6I") return "Ctrl+Shift+Tab (Ghostty)"
              if (clean == "^[[27;6;9~" || clean == "\\e[27;6;9~") return "Ctrl+Shift+Tab (CSI u)"
              if (clean == "^[[Z" || clean == "\\e[Z") return "Shift+Tab"

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

              if (match(clean, /^\^X\^([A-Z])$/, m)) return "Ctrl+X Ctrl+" m[1]
              if (match(clean, /^\^X(.)$/, m)) return "Ctrl+X " m[1]
              if (match(clean, /^\^\[([a-zA-Z0-9])$/, m)) return "Alt+" m[1]

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
              printf "%s\t%s\t%s\t%s\t%s\n", human, widget, mode, raw_key, d
            }
          '
        '';
      in
      {
        home.packages = with pkgs; [
          lsd
          zsh-list-keys-tv
        ];

        programs.zsh = {
          autosuggestion.enable = true;

          completionInit =
            # sh
            ''
              eval "$(herdr completion zsh)"
              autoload -U compinit && compinit
            '';

          enable = true;
          enableCompletion = true;

          fastSyntaxHighlighting = {
            enable = true;
            theme = "XDG:catppuccin-mocha";
          };

          history = {
            ignoreAllDups = true;

            ignorePatterns = [
              "rm *"
              "pkill *"
              "cp *"
            ];

            path = "${config.home.homeDirectory}/.zsh_history";
            size = 100000;
          };

          initContent =
            # zsh
            ''
              autoload -Uz bracketed-paste-url-magic
              zle -N bracketed-paste bracketed-paste-url-magic

              function up() {
                local d=""
                local limit=''${1:-1}

                for i in {1..$limit}; do
                  d+="../"
                done

                cd "$d"
              }

              function mkcd () {
                   mkdir "$1" && cd "$1"
               }

              function listening() {
                lsof -i -n -P | grep --color=auto \
                  --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} TCP |
                  grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} LISTEN
              }

              function extract() {
                if [ -f "$1" ]; then
                  case "$1" in
                  *.tar.bz2) tar xjf "$1" ;;
                  *.tar.gz) tar xzf "$1" ;;
                  *.bz2) bunzip2 "$1" ;;
                  *.rar) unrar x "$1" ;;
                  *.gz) gunzip "$1" ;;
                  *.tar) tar xf "$1" ;;
                  *.tbz2) tar xjf "$1" ;;
                  *.tgz) tar xzf "$1" ;;
                  *.zip) unzip "$1" ;;
                  *.Z) uncompress "$1" ;;
                  *.7z) 7z x "$1" ;;
                  *) echo "'$1' cannot be extracted via extract()" ;;
                  esac
                else
                  echo "'$1' is not a valid file"
                fi
              }

              function yt-mp3() {
                  yt-dlp -x --audio-format mp3 "$1"
              }

              function yt-flac() {
                  yt-dlp -x --audio-format flac --audio-quality 0 "$1"
              }

              function yt-album() {
                  yt-dlp -x --audio-format mp3 -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" "$1"
              }

              function yt-best() {
                  yt-dlp -f bestvideo+bestaudio --merge-output-format mkv "$1"
              }

              function yt-subs() {
                  yt-dlp --write-subs --write-auto-subs --skip-download "$1"
              }

              function spf() {
                  os=$(uname -s)

                  if [[ "$os" == "Linux" ]]; then
                      export SPF_LAST_DIR="${config.home.homeDirectory}/.local/state/superfile/lastdir"
                  fi

                  if [[ "$os" == "Darwin" ]]; then
                      export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
                  fi

                  command superfile "$@"

                  [ ! -f "$SPF_LAST_DIR" ] || {
                      . "$SPF_LAST_DIR"
                      rm -f -- "$SPF_LAST_DIR" > /dev/null
                  }
              }

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

              function zvm_after_init() {
                zvm_bindkey viins '^R' fzf-history-widget
                zvm_bindkey vicmd '^R' fzf-history-widget

                # Autosuggest Accept Keybindings (Ctrl+Tab only)
                zvm_bindkey viins '^[[27;5;9~' autosuggest-accept
                zvm_bindkey viins '^[[1;5I' autosuggest-accept
                zvm_bindkey viins '^[[9;5u' autosuggest-accept
              }

              eval "$(devenv hook zsh)"
              source $XDG_CONFIG_HOME/zsh/extra.zsh
            '';

          plugins = [
            {
              file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
              name = "zsh-vi-mode";
              src = pkgs.zsh-vi-mode;
            }
            {
              file = "share/fzf-tab/fzf-tab.plugin.zsh";
              name = "fzf-tab";
              src = pkgs.zsh-fzf-tab;
            }
          ];

          sessionVariables = {
            BROWSER = "zen-beta";
            EDITOR = "nvim";
            MANPAGER = "sh -c 'col -bx | bat -l man -p'";
            MANROFFOPT = "-c";
            NEWT_COLORS = "root=lavender,crust border=sapphire,base window=overlay0,base title=rosewater,crust button=surface2,lavender button_active=crust,maroon";
          };

          shellAliases = {
            "age" = "rage";
            "agyx" = "agy  --dangerously-skip-permissions";
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
            "grab" = "ghgrab --cwd";
            "grep" = "rg";
            "l" = "lsd -a";
            "la" = "lsd -la";
            "less" = "bat";
            "ll" = "lsd -l";
            "logs" = "journalctl --user -f -n 50";
            "ls" = "lsd";
            "lt" = "lsd --tree";
            "lzg" = "lazygit";
            "nho" = "nh os";
            "nixdev" = "nix develop";
            "nsh" = "nix-shell -p";
            "oc" = "opencode";
            "oc2" = "opencode2";
            "ocx" = "opencode --auto";
            "pingcf" = "ping 1.1.1.1";
            "pinggg" = "ping google.com";
            "rmr" = "rm -r";
            "t" = "tv --layout portrait --hide-preview --input-position bottom";
            "tls" = "tmux ls";
            "tn" = "sesh connect .";
            "todo" = "tuxedo";
            "top" = "btop";
            "ts" = "sesh last";
            "tvk" = "tv zsh-keys";
            "v" = "nvim";
            "vi" = "vim";
            "wh" = "which";
            "winbox" = "QT_QPA_PLATFORM=xcb WinBox | NUL";
            "wm" = "workmux";
            "wma" = "workmux add";
            "wmd" = "workmux dashboard -t worktrees";
            "wml" = "workmux list";
            "wmm" = "workmux merge";
            "wmo" = "workmux open";
            "wmq" = "workmux add --mode window --base main -l quickfix";
            "wms" = "workmux sidebar";
            "wmw" = "workmux add --mode window --base main -l agent-only";
            "y" = "yazi";
            "zen" = "zen-beta";
          };

          syntaxHighlighting.enable = false;
        };

        xdg.configFile."fsh".source = config.lib.file.mkOutOfStoreSymlink "${dotsPath}/fsh";

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

        xdg.configFile."zsh/extra.zsh".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/zsh/extra.zsh";
      };

    persistHome = {
      directories = [
        ".local/share/zsh"
      ];

      files = [
        ".zsh_history"
      ];
    };
  };

}
