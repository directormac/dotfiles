{
  inputs,
  lib,
  moduleWithSystem,
  ...
}:
{
  flake.nixosModules.zsh = moduleWithSystem (
    {
      pkgs,
      self',
      ...
    }:
    {
      nixpkgs.overlays = [
        (final: prev: {
          zsh = self'.packages.environment;
        })
      ];
      programs.zsh = {
        enable = true;
        enableCompletion = true;
        enableBashCompletion = true;
        autosuggestions.enable = true;
        syntaxHighlighting.enable = true;
        histSize = 100000;
      };
      users.defaultUserShell = pkgs.zsh;
    }
  );

  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    {
      packages.environment = inputs.wrappers.wrappers.zsh.wrap {
        inherit pkgs;
        runtimePkgs = [
          pkgs.fzf
          pkgs.zplug
          pkgs.zsh-fzf-tab
          pkgs.zsh-vi-mode
          pkgs.zsh-autosuggestions
        ];

        zshAliases = {
          c = "clear";
          cat = lib.getExe pkgs.bat;
          cd = "z";
          cda = "zoxide add";
          cdq = "zoxide query";
          cdr = "zoxide remove";
          ci = "zi";
          dotfiles = "cd ~/.dotfiles";
          du = lib.getExe pkgs.dust;
          find = lib.getExe pkgs.fd;
          grep = lib.getExe pkgs.ripgrep;
          l = "${lib.getExe pkgs.lsd} -a";
          la = "${lib.getExe pkgs.lsd} -la";
          lg = lib.getExe self'.packages.lazygit;
          ls = "${lib.getExe pkgs.lsd} -l";
          lt = "${lib.getExe pkgs.lsd} --tree";
          man = "man -P \"${lib.getExe pkgs.bat} -p\"";
          nsh = "nix-shell -p";
          flakecheck = "nix flake check ~/.dotfiles";
          nrsf = "sudo nixos-rebuild switch --flake ~/.dotfiles";
          top = lib.getExe pkgs.btop;
          wh = "which";
          y = lib.getExe pkgs.yazi;
        };

        zshrc.content = ''
          export LS_COLORS="$(${lib.getExe pkgs.vivid} generate catppuccin-mocha)"
          export EDITOR=nvim
          export TERMINAL="${lib.getExe self'.packages.terminal}"

          # fzf config...
          FZF_COMPLETION_TRIGGER='**'
          FZF_COMPLETION_OPTS='--border --info=inline'
          FZF_COMPLETION_PATH_OPTS='--walker file,dir,follow,hidden'
          FZF_COMPLETION_DIR_OPTS='--walker dir,follow'

          export FZF_DEFAULT_OPTS=$'
            --prompt="> " 
            --marker=">" 
            --pointer="◆" 
            --scrollbar="│" 
            --gutter=" " 
            --preview-border="line"
            --border="none"
            --separator="─"
            --padding="1"
            --highlight-line
            --color=fg:#CDD6F4,fg+:#CDD6F4,bg:-1,bg+:-1
            --color=hl:#F38BA8,hl+:#F38BA8,info:#CBA6F7,marker:#B4BEFE
            --color=prompt:#CBA6F7,spinner:#F5E0DC,pointer:#CBA6F7,header:#F38BA8
            --color=border:#6C7086,label:#CDD6F4,query:#F5E0DC'

          FZF_DEFAULT_FD_PARAMS="--strip-cwd-prefix --hidden --no-ignore --follow --exclude .git"

          FZF_ALT_C_COMMAND="fd --type d $FZF_DEFAULT_FD_PARAMS"
          FZF_CTRL_T_COMMAND="fd --type f $FZF_DEFAULT_FD_PARAMS"

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
          zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview '${lib.getExe pkgs.lsd} -la --color=always $realpath'
          zstyle ':fzf-tab:complete:cd:*' fzf-preview '${lib.getExe pkgs.lsd} -la --color=always $realpath'
          zstyle ':fzf-tab:complete:cd:*' popup-pad 30 0

          source ${pkgs.zsh-vi-mode}/share/zsh-vi-mode/zsh-vi-mode.plugin.zsh
          source <(${lib.getExe pkgs.fzf} --zsh)

          eval "$(${lib.getExe pkgs.devenv} hook zsh)"
          eval "$(${lib.getExe self'.packages.starship} init zsh)"
          eval "$(${lib.getExe pkgs.zoxide} init zsh)"

          function zvm_after_init() {
            zvm_bindkey viins '^ ' autosuggest-accept
            zvm_bindkey viins '\e[27;5;9~' autosuggest-accept
          }

          bindkey '^ ' autosuggest-accept
          bindkey '\e[27;5;9~' autosuggest-accept

          source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
        '';
      };
    };
}
