{
  lib,
  self,
  ...
}:
{

  flake.homeModules.zsh = { pkgs, ... }: {

    programs.zsh = {
      enable = true;

      shellGlobalAliases = {
        "c" = "clear";
        "cat" = "bat";
        "cd " = "z";
        "cda" = "zoxide add";
        "cdq" = "zoxide query";
        "cdr" = "zoxide remove";
        "ci" = "zi";
        "dotfiles" = "cd ~/.dotfiles";
        "du" = "dust";
        "find" = "fd";
        "grep" = "ripgrep";
        "l" = "lsd -a";
        "ll" = "lsd -l";
        "la" = "lsd -la";
        "lg" = "lazygit";
        "ls" = "lsd";
        "lt" = "lsd --tree";
        "man" = "man -P bat -p";
        "nsh" = "nix-shell -p";
        "flakecheck" = "nix flake check ~/.dotfiles/_fallback";
        "nrsf" = "sudo nixos-rebuild switch --flake ~/.dotfiles/_fallback";
        "top" = "btop";
        "wh" = "which";
        "y" = "yazi";
        "zen" = "zen-beta";
        "wm" = "workmux";
      };

      sessionVariables = {
        EDITOR = "lvim";
        LS_COLORS = "$(vivid generate catppuccin-mocha)";
        BROWSER = "zen-beta";
        FZF_COMPLETION_TRIGGER = "**";
        FZF_COMPLETION_OPTS = "--border --info=inline";
        FZF_COMPLETION_PATH_OPTS = "--walker file,dir,follow,hidden";
        FZF_COMPLETION_DIR_OPTS = "--walker dir,follow";

      };

      initContent = ''

        FZF_TAB_GROUP_COLORS=(
          $'\033[94m' $'\033[32m' $'\033[33m' $'\033[35m' $'\033[31m' $'\033[38;5;27m' $'\033[36m'
          $'\033[38;5;100m' $'\033[38;5;98m' $'\033[91m' $'\033[38;5;80m' $'\033[92m'
          $'\033[38;5;214m' $'\033[38;5;165m' $'\033[38;5;124m' $'\033[38;5;120m'
        )
        FZF_CTRL_T_OPTS="
          --walker-skip .git,node_modules,target
          --preview 'bat -n --color=always {}'
          --bind 'ctrl-/:change-preview-window(down|hidden|)'"

        FZF_ALT_C_OPTS="
          --walker-skip .git,node_modules,target
          --preview 'tree -C {}'"

        FZF_CTRL_R_OPTS="
          --layout=reverse
          --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
          --color header:italic
          --header 'Press CTRL-Y to copy command into clipboard'"

        zstyle ':completion:*:descriptions' format '[%d]'

        zstyle ':fzf-tab:*' fzf-bindings 'space:accept'
        zstyle ':fzf-tab:*' switch-group '<' '>'
        zstyle ':fzf-tab:*' use-fzf-default-opts yes
        zstyle ':fzf-tab:complete:_zlua:*' query-string input
        zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'lsd -la --color=always $realpath'
        zstyle ':fzf-tab:complete:cd:*' fzf-preview 'lsd -la --color=always $realpath'
        zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0

        source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh

        source <(${lib.getExe pkgs.fzf} --zsh)

        eval "$(devenv hook zsh)"
        eval "$(starship init zsh)"
        eval "$(zoxide init zsh)"

        function zvm_after_init() {
          zvm_bindkey viins '^ ' autosuggest-accept
          zvm_bindkey viins '\e[27;5;9~' autosuggest-accept
        }

        bindkey '^ ' autosuggest-accept
        bindkey '\e[27;5;9~' autosuggest-accept

        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      '';

      fastSyntaxHighlighting = {
        # https://github.com/zdharma-continuum/fast-syntax-highlighting/blob/master/THEME_GUIDE.md
        theme =
          # ini
          ''
            [base]
            default          = #cdd6f4
            unknown-token    = #f38ba8,bold
            commandseparator = #94e2d5
            redirection      = #94e2d5
            here-string-tri  = #bac2de
            here-string-text = #bac2de
            here-string-var  = #bac2de
            exec-descriptor  = none
            comment          = #6c7086
            correct-subtle   = #b4befe
            incorrect-subtle = #eba0ac
            subtle-separator = none
            subtle-bg        = none
            secondary        =
            recursive-base   = #cdd6f4

            [command-point]
            reserved-word     = #cba6f7
            subcommand        = #74c7ec
            alias             = #89b4fa
            suffix-alias      = #89b4fa
            global-alias      = #89b4fa
            builtin           = #cba6f7
            function          = #89b4fa
            command           = #89b4fa
            precommand        = #cba6f7
            hashed-command    = #89b4fa
            single-sq-bracket = #f9e2af
            double-sq-bracket = #f9e2af
            double-paren      = #a6e3a1

            [paths]
            path          = #f5e0dc
            pathseparator = #f5e0dc
            path-to-dir   = #f5e0dc
            globbing      = #f5c2e7
            globbing-ext  = none

            [brackets]
            paired-bracket  = bold
            bracket-level-1 = #f38ba8
            bracket-level-2 = #f9e2af
            bracket-level-3 = #74c7ec

            [arguments]
            single-hyphen-option   = #94e2d5
            double-hyphen-option   = #94e2d5
            back-quoted-argument   = #94e2d5
            single-quoted-argument = #a6e3a1
            double-quoted-argument = #a6e3a1
            dollar-quoted-argument = #a6e3a1
            optarg-string          = #a6e3a1
            optarg-number          = #fab387

            [in-string]
            back-dollar-quoted-argument           = #fab387
            back-or-dollar-double-quoted-argument = #fab387

            [other]
            variable             = #fab387
            assign               = none
            assign-array-bracket = none
            history-expansion    = none

            [math]
            mathvar = #f5c2e7
            mathnum = #fab387
            matherr = #f38ba8,bold

            [for-loop]
            forvar  = #cdd6f4
            fornum  = #fab387
            foroper = #89b4fa
            forsep  = #89b4fa

            [case]
            case-input       = #fab387
            case-parentheses = #9399b2
            case-condition   = #cba6f7
          '';
      };

    };

    programs.fzf = {
      enable = true;
      # https://github.com/junegunn/fzf/wiki/Color-schemes
      colors = { };
      enableBashIntegration = true;
      enableZshIntegration = true;

      defaultOptions = [
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
        "--color=fg:#CDD6F4,fg+:#CDD6F4,bg:-1,bg+:-1"
        "--color=hl:#F38BA8,hl+:#F38BA8,info:#CBA6F7,marker:#B4BEFE"
        "--color=prompt:#CBA6F7,spinner:#F5E0DC,pointer:#CBA6F7,header:#F38BA8"
        "--color=border:#6C7086,label:#CDD6F4,query:#F5E0DC"
      ];

      # Command line options for the ALT-C keybinding.
      changeDirWidget = {
        command = "fd --type d";
        options = [
          "--strip-cwd-prefix"
          "--hidden"
          "--no-ignore"
          "--follow"
          "--exclude .git"
        ];
      };

      # Command line options for the CTRL-T keybinding.
      fileWidget = {
        command = "fd --type f";
        options = [
          "--strip-cwd-prefix"
          "--hidden"
          "--no-ignore"
          "--follow"
          "--exclude .git"
        ];
      };

      # The command that gets executed as the source for fzf for the CTRL-R keybinding.
      # https://search.nixos.org/options?channel=unstable&query=programs.fzf&source=home_manager&type=options
      historyWidget = {
        command = null;
        options = [
          "--layout=reverse"
          "--bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'"
          "--color header:italic"
          "--header 'Press CTRL-Y to copy command into clipboard'"
        ];
      };

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
        syntaxHighlighting.enable = true;
        histSize = 100000;
      };
      users.defaultUserShell = pkgs.zsh;

      environment.systemPackages = with pkgs; [
        zinit
        tree
        zsh-fzf-tab
        zsh-vi-mode
        zsh-autosuggestions
      ];
    };

}
