# Workmux Git Worktree Multiplexer Aspect
{
  den,
  inputs,
  lib,
  ...
}:
{
  flake-file.inputs = {
    workmux.url = "github:raine/workmux";
  };

  den.aspects.applications.dev.mux.workmux = {
    nixos =
      { pkgs, ... }:
      {
        environment.systemPackages = lib.optionals (inputs ? workmux) [
          inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default
        ];
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
        workmuxPkg =
          if pkgs ? llm-agents && pkgs.llm-agents ? workmux then
            pkgs.llm-agents.workmux
          else if inputs ? workmux then
            inputs.workmux.packages.${pkgs.stdenv.hostPlatform.system}.default
          else
            null;
      in
      {
        home.packages = lib.optional (workmuxPkg != null) workmuxPkg;

        xdg.configFile."workmux/config.yaml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/workmux/config.yaml";

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
      };
  };
}
