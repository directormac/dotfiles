# Zellij Terminal Multiplexer Aspect
{
  den.aspects.applications.dev.mux.zellij = {
    homeManager =
      {
        config,
        pkgs,
        ...
      }:
      let
        zjstatusHintsWasm = pkgs.fetchurl {
          sha256 = "sha256-k2xV6QJcDtvUNCE4PvwVG9/ceOkk+Wa/6efGgr7IcZ0=";
          url = "https://github.com/b0o/zjstatus-hints/releases/latest/download/zjstatus-hints.wasm";
        };
      in
      {
        programs.zellij = {
          enable = true;
          attachExistingSession = false;
          enableBashIntegration = false;
          enableZshIntegration = false;

          extraConfig = ''
            plugins {
                zjstatus-hints location="file:${config.xdg.configHome}/zellij/plugins/zjstatus-hints.wasm" {
                    max_length 0
                    overflow_str "..."
                    pipe_name "zjstatus_hints"
                    hide_in_base_mode false
                }
            }

            load_plugins {
                zjstatus-hints
            }
          '';

          layouts = {
            default =
              # kdl
              ''
                layout {
                  pane split_direction="vertical" {
                    pane
                  }

                  pane size=1 borderless=true {
                    plugin location="file:${config.xdg.configHome}/zellij/plugins/zjstatus.wasm" {
                      hide_frame_for_single_pane "true"

                      format_left  "{mode}#[fg=#89B4FA,bg=#181825,bold] {session}#[bg=#181825] {tabs}"
                      format_right "{pipe_zjstatus_hints}#[fg=#424554,bg=#181825]::{datetime}"
                      format_space "#[bg=#181825]"

                      mode_normal         "#[bg=#89B4FA] "
                      mode_tmux           "#[bg=#ffc387] "
                      mode_default_to_mode "tmux"

                      tab_normal               "#[fg=#6C7086,bg=#181825] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                      tab_active               "#[fg=#9399B2,bg=#181825,bold,italic] {index} {name} {fullscreen_indicator}{sync_indicator}{floating_indicator}"
                      tab_fullscreen_indicator "□ "
                      tab_sync_indicator       "  "
                      tab_floating_indicator   "󰉈 "

                      command_kubectx_command  "kubectx -c"
                      command_kubectx_format   "#[fg=#6C7086,bg=#181825,italic] {stdout}"
                      command_kubectx_interval "2"

                      command_kubens_command   "kubens -c"
                      command_kubens_format    "#[fg=#6C7086,bg=#181825]{stdout} "
                      command_kubens_interval  "2"

                      datetime          "#[fg=#9399B2,bg=#181825] {format} "
                      datetime_format   "%A, %d %b %Y %H:%M"
                      datetime_timezone "Europe/Berlin"
                    }
                  }
                }
              '';

            dev =
              # kdl
              ''
                layout {
                    default_tab_template {
                        pane size=1 borderless=true {
                            plugin location="zellij:tab-bar"
                        }
                        children
                        pane size=2 borderless=true {
                            plugin location="zellij:status-bar"
                        }
                    }

                    tab name="Project" focus=true {
                        pane command="nvim"
                    }

                    tab name="Git" {
                        pane command="lazygit"
                    }

                    tab name="Files" {
                        pane command="yazi"
                    }

                    tab name="Shell" {
                        pane command="zsh"
                    }
                }
              '';
          };

          plugins = with pkgs.zellijPlugins; [
            zjstatus
            zjframes
            workspace
          ];
        };

        stylix.targets.zellij.enable = true;
        xdg.configFile."zellij/plugins/zjstatus-hints.wasm".source = zjstatusHintsWasm;
      };

    persistHome.directories = [
      ".local/share/zellij"
    ];
  };
}
