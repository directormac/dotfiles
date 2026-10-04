{ inputs, self, ... }: {
  flake.homeModules.multiplexer =
    { pkgs, config, ... }:
    {

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
      zellij
    ];

  };

}
