# Workmux Git Worktree Multiplexer Aspect
{
  lib,
  inputs,
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
        tv-git-worktree-preview = pkgs.writeShellScript "tv-git-worktree-preview" ''
          branch="$1"
          head="$2"
          path="$3"
          echo -e "╭── Git Worktree: $branch ($head) ───"
          echo -e "│ Path: $path"
          echo -e "├── Git Status ────────────────────────────────────"
          ${pkgs.git}/bin/git -C "$path" status --short 2>/dev/null || echo "Not a git directory"
          echo -e "├── Recent Commits ────────────────────────────────"
          ${pkgs.git}/bin/git -C "$path" log --oneline -8 --color=always 2>/dev/null || true
          echo -e "╰──────────────────────────────────────────────────"
        '';
        tv-workmux-preview = pkgs.writeShellScript "tv-workmux-preview" ''
          handle="$1"
          branch="$2"
          path="$3"
          echo -e "╭── Workmux Worktree: $handle ($branch) ───"
          echo -e "│ Path: $path"
          echo -e "├── Git Status ────────────────────────────────────"
          ${pkgs.git}/bin/git -C "$path" status --short 2>/dev/null || echo "Not a git directory"
          echo -e "├── Recent Commits ────────────────────────────────"
          ${pkgs.git}/bin/git -C "$path" log --oneline -8 --color=always 2>/dev/null || true
          echo -e "╰──────────────────────────────────────────────────"
        '';
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

        xdg.configFile."television/cable/git-worktrees.toml".text =
          # toml
          ''
            [metadata]
            name = "git-worktrees"
            description = "List, inspect, and switch between Git worktrees"
            requirements = ["git"]

            [source]
            command = "git worktree list --porcelain | awk '/^worktree / {path=substr($0, 10)} /^branch refs\\/heads\\// {sub(/^branch refs\\/heads\\//, \"\"); branch=$0} /^HEAD / {head=substr($2,1,7)} /^$/ {if (path!=\"\") {print (branch ? branch : \"detached\") \"\\t\" head \"\\t\" path; path=\"\"; branch=\"\"; head=\"\"}} END {if (path!=\"\") print (branch ? branch : \"detached\") \"\\t\" head \"\\t\" path}'"
            display = "{split:\t:0}  │  {split:\t:1}  │  {split:\t:2}"
            output = "{split:\t:2}"

            [preview]
            command = "${tv-git-worktree-preview} '{split:\t:0}' '{split:\t:1}' '{}'"

            [keybindings]
            enter = "actions:cd"
            ctrl-e = "actions:edit"
            ctrl-d = "actions:remove"
            ctrl-y = "actions:copy_path"
            [actions.cd]
            description = "Switch into this worktree shell"
            command = "cd '{}' && $SHELL"
            mode = "execute"

            [actions.edit]
            description = "Open worktree directory in editor"
            command = "''${EDITOR:-nvim} '{}'"
            mode = "execute"

            [actions.open_terminal]
            description = "Open new Ghostty terminal in worktree"
            command = "ghostty --working-directory='{}'"
            mode = "fork"

            [actions.open_herdr]
            description = "Open worktree in Herdr workspace"
            command = "herdr worktree open --path '{}' --focus"
            mode = "execute"

            [actions.open_workmux]
            description = "Open worktree in workmux"
            command = "workmux open '{split:\t:0}'"
            mode = "fork"

            [actions.copy_path]
            description = "Copy worktree path to clipboard"
            command = "echo -n '{}' | wl-copy"
            mode = "execute"

            [actions.remove]
            description = "Remove this Git worktree"
            command = "git worktree remove '{}'"
            mode = "execute"
          '';

        # Television cable for workmux
        xdg.configFile."television/cable/workmux.toml".text =
          # toml
          ''
            [metadata]
            name = "workmux"
            description = "List, inspect, and switch between workmux worktrees"
            requirements = ["workmux", "jq"]

            [source]
            command = "workmux list --json 2>/dev/null | jq -r '.[] | .handle + \"\\t\" + .branch + \"\\t\" + .path'"
            display = "{split:\t:0}  │  {split:\t:1}  │  {split:\t:2}"
            output = "{split:\t:0}"

            [preview]
            command = "${tv-workmux-preview} '{}' '{split:\t:1}' '{split:\t:2}'"

            [keybindings]
            enter = "actions:open"
            ctrl-e = "actions:edit"
            ctrl-d = "actions:close"
            ctrl-y = "actions:copy_path"
            [actions.open]
            description = "Open or switch to selected worktree in tmux"
            command = "workmux open '{}'"
            mode = "fork"

            [actions.edit]
            description = "Open worktree directory in editor"
            command = "''${EDITOR:-nvim} '{split:\t:2}'"
            mode = "execute"

            [actions.open_terminal]
            description = "Open new Ghostty terminal in worktree directory"
            command = "ghostty --working-directory='{split:\t:2}'"
            mode = "fork"

            [actions.close]
            description = "Close the selected worktree window/session"
            command = "workmux close '{}'"
            mode = "fork"

            [actions.copy_path]
            description = "Copy worktree path to clipboard"
            command = "echo -n '{split:\t:2}' | wl-copy"
            mode = "execute"
          '';

        xdg.configFile."workmux/config.yaml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/workmux/config.yaml";
      };
  };
}
