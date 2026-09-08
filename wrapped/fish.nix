{
  inputs,
  lib,
  ...
}:
{
  perSystem =
    {
      pkgs,
      self',
      ...
    }:
    let
      plugins = [
        pkgs.fishPlugins.fzf
        pkgs.fishPlugins.fzf-fish
      ];

      pluginConf = lib.concatMapStringsSep "\n" (plugin: ''
        if test -d ${plugin}/share/fish/vendor_functions.d
            set -p fish_function_path ${plugin}/share/fish/vendor_functions.d
        end
        if test -d ${plugin}/share/fish/vendor_completions.d
            set -p fish_complete_path ${plugin}/share/fish/vendor_completions.d
        end
        if test -d ${plugin}/share/fish/vendor_conf.d
            for f in ${plugin}/share/fish/vendor_conf.d/*.fish
                source $f
            end
        end
      '') plugins;

      fishConf =
        pkgs.writeText "fishy-fishy"
          # fish
          ''
            #Set SHELL to fish so fzf uses it for previews (fixes 'string: command not found' in fzf-fish)
            set -gx SHELL (command -v fish)

            function fish_prompt
                string join "" -- (set_color red) "[" (set_color yellow) $USER (set_color green) "@" (set_color blue) $hostname (set_color magenta) " " $(prompt_pwd) (set_color red) ']' (set_color normal) "\$ "
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

            set -gx FZF_DEFAULT_OPTS '
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

            set -gx FZF_DEFAULT_FD_PARAMS "--strip-cwd-prefix --hidden --no-ignore --follow --exclude .git"

            set -gx FZF_ALT_C_COMMAND "fd --type d \$FZF_DEFAULT_FD_PARAMS"
            set -gx FZF_CTRL_T_COMMAND "fd --type f \$FZF_DEFAULT_FD_PARAMS"

            set -gx FZF_CTRL_T_OPTS "
              --walker-skip .git,node_modules,target
              --preview 'bat -n --color=always {}'
              --bind 'ctrl-/:change-preview-window(down|hidden|)'"

            set -gx FZF_ALT_C_OPTS "
              --walker-skip .git,node_modules,target
              --preview 'tree -C {}'"

            set -gx FZF_CTRL_R_OPTS "
              --layout=reverse
              --bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy)+abort'
              --color header:italic
              --header 'Press CTRL-Y to copy command into clipboard'"

            ${pluginConf}

            ${lib.getExe self'.packages.starship} init fish | source
            ${lib.getExe pkgs.zoxide} init fish | source
          '';
    in
    {
      packages.fish = inputs.lwrappers.lib.wrapPackage {
        inherit pkgs;
        package = pkgs.fish;
        runtimeInputs = [
          pkgs.zoxide
        ]
        ++ plugins;
        flags = {
          "-C" = "source ${fishConf}";
        };
      };
    };
}
