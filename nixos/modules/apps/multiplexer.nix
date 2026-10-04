{
  inputs,
  self,
  lib,
  ...
}:
{
  flake.homeModules.multiplexer =
    { pkgs, config, ... }:
    # let
    #   # Fetch the external .wasm plugin from GitHub releases
    #   zjstatusHintsWasm = builtins.fetchurl {
    #     url = "https://github.com/b0o/zjstatus-hints/releases/latest/download/zjstatus-hints.wasm";
    #     # Optional: you can add a sha256 hash here if you want strict reproducibility,
    #     # but omitting it allows `fetchurl` to track updates when evaluating if desired.
    #     # sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    #   };
    # in
    # let
    #   # Package the non-nixpkgs plugin so Home Manager manages it natively
    #   zjstatusHints = pkgs.stdenv.mkDerivation {
    #     pname = "zellij-zjstatus-hints";
    #     version = "latest";
    #     src = pkgs.fetchurl {
    #       url = "https://github.com/b0o/zjstatus-hints/releases/latest/download/zjstatus-hints.wasm";
    #       sha256 = lib.fakeSha256; # Replace with real sha256 on first build failure
    #     };
    #     dontUnpack = true;
    #     installPhase = ''
    #       mkdir -p $out/bin
    #       cp $src $out/zjstatus-hints.wasm
    #       # Home Manager expects the .wasm file to match the derivation structure
    #       # or you can place it directly where it needs to go.
    #     '';
    #   };
    # in
    let
      zjstatusHintsWasm = pkgs.fetchurl {
        url = "https://github.com/b0o/zjstatus-hints/releases/latest/download/zjstatus-hints.wasm";
        # lib.fakeSha256; # Will fail on first build and show the correct hash to paste here
        sha256 = "sha256-k2xV6QJcDtvUNCE4PvwVG9/ceOkk+Wa/6efGgr7IcZ0=";
      };
    in
    {

      # imports = [ inputs.yazelix.homeManagerModules.default ];

      home.packages = [
        inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];

      # https://workmux.raine.dev/guide/configuration/
      xdg.configFile."workmux/config.yaml".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.dotfiles/config/workmux/config.yaml";

      # Television cable for workmux
      xdg.configFile."television/cable/workmux.toml".text =
        # toml
        ''
          [metadata]
          name = "workmux"
          description = "List and switch between workmux worktrees"
          requirements = ["workmux", "jq"]

          [source]
          command = "workmux list --json 2>/dev/null | jq -r '.[] | .handle + \"\\t\" + .branch + \"\\t\" + .path'"

          [preview]
          command = "cd '{split:\\t:2}' 2>/dev/null && git log --oneline -10 --color=always && echo && git status --short"

          [keybindings]
          enter = "actions:open"
          ctrl-d = "actions:close"

          [actions.open]
          description = "Open or switch to selected worktree in tmux"
          command = "workmux open '{split:\\t:0}'"
          mode = "fork"

          [actions.close]
          description = "Close the selected worktree window/session"
          command = "workmux close '{split:\\t:0}'"
          mode = "fork"
        '';

      xdg.configFile."television/cable/git-worktrees.toml".text =
        # toml
        ''
          [metadata]
          name = "git-worktrees"
          description = "List and switch between git worktrees"
          requirements = ["git"]

          [source]
          command = "git worktree list --porcelain | grep '^worktree' | cut -d' ' -f2-"

          [preview]
          command = "cd '{}' && git log --oneline -10 --color=always && echo && git status --short"

          [keybindings]
          enter = "actions:cd"
          ctrl-d = "actions:remove"

          [actions.cd]
          description = "Change to the selected worktree"
          command = "cd {} && $SHELL"
          mode = "execute"

          [actions.remove]
          description = "Remove the selected worktree"
          command = "git worktree remove {}"
          mode = "execute"
        '';

      # [sesh.nix](https://github.com/nix-community/home-manager/blob/master/modules/programs/sesh.nix)
      programs.sesh = {
        enable = true;
        enableAlias = true;

        # See the [sesh documentation](https://github.com/joshmedeski/sesh#configuration) for available options.
        settings = {
          wildcard = [
            {
              pattern = "~/Projects/*";
              windows = [
                "editor"
                "terminal"
              ];
            }
            {
              pattern = "~/Code/.worktrees/*/*";
              windows = [
                "editor"
                "terminal"
                "lazygit"
              ];
            }
          ];
          session = [
            {
              name = "Dotfiles";
              path = "~/.dotfiles";
            }
            {
              name = "Config";
              path = "~/.dotfiles/config";
            }
            {
              name = "Default";
              path = "~/";
            }
          ];
          window = [
            {
              name = "editor";
              startup_script = "nvim";
            }
            {
              name = "terminal";
              startup_script = "clear";
            }
            {
              name = "lazygit";
              startup_script = "lazygit";
            }
            {
              name = "agent";
              startup_script = "agy";
            }
          ];
        };
      };

      stylix.targets.zellij.enable = true;
      xdg.configFile."zellij/plugins/zjstatus-hints.wasm".source = zjstatusHintsWasm;

      programs.zellij = {
        enable = true;
        enableBashIntegration = false;
        enableZshIntegration = false;
        attachExistingSession = false;
        layouts = {
          # 1. Your customized default layout using zjstatus
          default =
            # kdl
            ''
              layout {
                pane split_direction="vertical" {
                  pane
                }

                pane size=1 borderless=true {
                  plugin location="file:/home/artifex/.config/zellij/plugins/zjstatus.wasm" {
                    hide_frame_for_single_pane "true"

                    format_left  "{mode}#[fg=#89B4FA,bg=#181825,bold] {session}#[bg=#181825] {tabs}"
                    format_right "{pipe_zjstatus_hints}#[fg=#424554,bg=#181825]::{datetime}"
                    // format_right "#[fg=#424554,bg=#181825]::{datetime}"
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

          # 2. Your multi-tab dev layout for nvim, lazygit, yazi, and shell
          dev = ''
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
          # https://github.com/karimould/zellij-forgot

          # https://github.com/Nacho114/harpoon
          # https://github.com/laperlej/zellij-sessionizer
          # https://github.com/sharph/zellij-worktree
          #https://github.com/dj95/zj-smart-sessions
          # https://github.com/dj95/zj-quit
          # vim-zellij-navigator
        ];

        # Register and load the un-packaged plugin via extraConfig or settings
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

      };

      # https://github.com/Yazelix/nova/blob/stable/docs/installation.md
      # programs.yazelix.enable = true;

    };

  flake.nixosModules.multiplexer = { pkgs, config, ... }: {

    home-manager.users.${config.preferences.user.name} = {
      imports = [
        self.homeModules.multiplexer
      ];
    };

    environment.systemPackages = with pkgs; [
      inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default
      sesh
    ];

  };

}
