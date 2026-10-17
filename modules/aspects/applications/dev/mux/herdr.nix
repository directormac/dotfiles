# Herdr Multiplexer Aspect: LLM Agents management service and out-of-store config symlink
{
  inputs,
  ...
}:
{
  den.aspects.applications.dev.mux.herdr = {
    homeManager =
      {
        config,
        pkgs,
        user,
        ...
      }:
      let
        dotsPath = user.dotsConfigPath or "/home/${user.name}/.dotfiles/config";
        herdrPkg =
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr
            or (pkgs.writeShellScriptBin "herdr" "echo herdr");
      in
      {
        home.file.".config/herdr/config.toml".source =
          config.lib.file.mkOutOfStoreSymlink "${dotsPath}/herdr/config.toml";

        home.packages = [ herdrPkg ];

        systemd.user.services.herdr-server = {
          Install.WantedBy = [ "graphical-session.target" ];

          Service = {
            ExecStart = "${herdrPkg}/bin/herdr server";
            KillMode = "mixed";
            Type = "forking";
          };

          Unit = {
            After = [ "graphical-session.target" ];
            Description = "Herdr Server";
            Documentation = "herdr --help";
          };
        };

        xdg.configFile."television/cable/herdr-agents.toml".text =
          # toml
          ''
            [metadata]
            name = "herdr-agents"
            description = "Inspect and interact with coding agents in Herdr"
            requirements = ["herdr", "jq"]

            [source]
            command = "herdr agent list 2>/dev/null | jq -r '.result.agents[]? | [.agent, .agent_status, .workspace_id, .tab_id, .pane_id, .cwd, .terminal_title_stripped] | @tsv'"
            display = "{split:\t:0}  │  [{split:\t:1}]  │  {split:\t:2} (tab: {split:\t:3})  │  {split:\t:5}"
            output = "{split:\t:4}"

            [preview]
            command = '''bash -c '
              agent="{split:\t:0}"
              status="{split:\t:1}"
              pane="{}"
              cwd="{split:\t:5}"
              title="{split:\t:6}"
              echo -e "╭── Herdr Agent: $agent ──────────────────────────"
              echo -e "│ Status: $status"
              echo -e "│ Pane:   $pane"
              echo -e "│ CWD:    $cwd"
              echo -e "│ Title:  $title"
              echo -e "├── Recent Output ─────────────────────────────────"
              herdr agent read "$agent" --lines 30 2>/dev/null || herdr pane read "$pane" --lines 30 2>/dev/null
              echo -e "╰──────────────────────────────────────────────────"
            ' '''

            [keybindings]
            enter = "actions:focus"
            ctrl-k = "actions:interrupt"
            ctrl-w = "actions:wait"
            ctrl-y = "actions:copy_agent"

            [actions.focus]
            description = "Focus pane running this agent"
            command = "herdr pane focus '{}'"
            mode = "execute"

            [actions.interrupt]
            description = "Send Ctrl+C to agent"
            command = "herdr agent send-keys '{split:\t:0}' ctrl+c"
            mode = "execute"

            [actions.wait]
            description = "Wait for agent to become idle or done"
            command = "herdr agent wait '{split:\t:0}'"
            mode = "execute"

            [actions.copy_agent]
            description = "Copy agent name to clipboard"
            command = "echo -n '{split:\t:0}' | wl-copy"
            mode = "execute"
          '';

        xdg.configFile."television/cable/herdr-sessions.toml".text =
          # toml
          ''
            [metadata]
            name = "herdr-sessions"
            description = "Manage Herdr persistent sessions (attach, stop, delete, inspect)"
            requirements = ["herdr", "jq"]

            [source]
            command = "herdr session list --json 2>/dev/null | jq -r '.sessions[] | [(if .running then \"🟢 Running\" else \"⚪ Stopped\" end), .name, (if .default then \"[default]\" else \"\" end), .session_dir] | @tsv'"
            display = "{split:\t:0}  │  {split:\t:1} {split:\t:2}  │  {split:\t:3}"
            output = "{split:\t:1}"

            [preview]
            command = '''bash -c '
              name="{}"
              sess=$(herdr session list --json 2>/dev/null | jq -r --arg n "$name" ".sessions[] | select(.name == \$n)")
              running=$(echo "$sess" | jq -r ".running")
              dir=$(echo "$sess" | jq -r ".session_dir")
              sock=$(echo "$sess" | jq -r ".socket_path")
              echo -e "╭── Herdr Session: $name ──────────────────────────"
              echo -e "│ Status:    $([ "$running" = "true" ] && echo "🟢 Running" || echo "⚪ Stopped")"
              echo -e "│ Directory: $dir"
              echo -e "│ Socket:    $sock"
              if [ "$running" = "true" ]; then
                echo -e "├── Workspaces ────────────────────────────────────"
                herdr --session "$name" workspace list 2>/dev/null | jq -r ".result.workspaces[]? | \"│  • [\(.workspace_id)] \(.label) (tabs: \(.tab_count), panes: \(.pane_count), agent: \(.agent_status))\""
                echo -e "├── Tabs ──────────────────────────────────────────"
                herdr --session "$name" tab list 2>/dev/null | jq -r ".result.tabs[]? | \"│  • [\(.tab_id)] \(.label) (panes: \(.pane_count))\""
              else
                echo -e "│ (Session is stopped. Press Enter to start or attach)"
              fi
              echo -e "╰──────────────────────────────────────────────────"
            ' '''

            [keybindings]
            enter = "actions:attach"
            ctrl-t = "actions:open_terminal"
            ctrl-s = "actions:stop"
            ctrl-d = "actions:delete"
            ctrl-y = "actions:copy_name"

            [actions.attach]
            description = "Attach to this Herdr session"
            command = "herdr session attach '{}'"
            mode = "execute"

            [actions.open_terminal]
            description = "Open session attach in a new Ghostty terminal window"
            command = "ghostty -e herdr session attach '{}'"
            mode = "fork"

            [actions.stop]
            description = "Stop this running session"
            command = "herdr session stop '{}'"
            mode = "execute"

            [actions.delete]
            description = "Delete this session"
            command = "herdr session delete '{}'"
            mode = "execute"

            [actions.copy_name]
            description = "Copy session name to clipboard"
            command = "echo -n '{}' | wl-copy"
            mode = "execute"
          '';

        xdg.configFile."television/cable/herdr-workspaces.toml".text =
          # toml
          ''
            [metadata]
            name = "herdr-workspaces"
            description = "Inspect and switch Herdr workspaces"
            requirements = ["herdr", "jq"]

            [source]
            command = "herdr workspace list 2>/dev/null | jq -r '.result.workspaces[]? | [.workspace_id, .label, (if .focused then \"Focused\" else \"Idle\" end), (.tab_count|tostring), (.pane_count|tostring), .agent_status, (.worktree.checkout_path // \"none\")] | @tsv'"
            display = "[{split:\t:0}] {split:\t:1}  │  {split:\t:2}  │  Tabs: {split:\t:3}  Panes: {split:\t:4}  │  Agent: {split:\t:5}"
            output = "{split:\t:0}"

            [preview]
            command = '''bash -c '
              ws="{}"
              echo -e "╭── Herdr Workspace: $ws ──────────────────────────"
              herdr workspace get "$ws" 2>/dev/null | jq -r ".result.workspace | \"│ Label:    \(.label)\n│ Focused:  \(.focused)\n│ Worktree: \(.worktree.checkout_path // \"None\")\""
              echo -e "├── Tabs ──────────────────────────────────────────"
              herdr tab list --workspace "$ws" 2>/dev/null | jq -r ".result.tabs[]? | \"│  • [\(.tab_id)] \(.label) (panes: \(.pane_count), agent: \(.agent_status))\""
              echo -e "├── Panes & Agents ────────────────────────────────"
              herdr pane list --workspace "$ws" 2>/dev/null | jq -r ".result.panes[]? | \"│  • [\(.pane_id)] \(.label) (agent: \(.agent // \"none\"), cwd: \(.cwd))\""
              echo -e "╰──────────────────────────────────────────────────"
            ' '''

            [keybindings]
            enter = "actions:focus"
            ctrl-x = "actions:close"
            ctrl-d = "actions:close"
            ctrl-y = "actions:copy_id"

            [actions.focus]
            description = "Focus this Herdr workspace"
            command = "herdr workspace focus '{}'"
            mode = "execute"

            [actions.close]
            description = "Close this Herdr workspace"
            command = "herdr workspace close '{}'"
            mode = "execute"

            [actions.copy_id]
            description = "Copy workspace ID to clipboard"
            command = "echo -n '{}' | wl-copy"
            mode = "execute"
          '';

        xdg.configFile."television/cable/herdr-worktrees.toml".text =
          # toml
          ''
            [metadata]
            name = "herdr-worktrees"
            description = "Manage Git worktree-backed workspaces in Herdr"
            requirements = ["herdr", "git", "jq"]

            [source]
            command = "herdr worktree list 2>/dev/null | jq -r '.result.worktrees[]? | [.branch, (if .open_workspace_id then \"Open (\" + .open_workspace_id + \")\" else \"Closed\" end), .path] | @tsv'"
            display = "{split:\t:0}  │  {split:\t:1}  │  {split:\t:2}"
            output = "{split:\t:2}"

            [preview]
            command = '''bash -c '
              branch="{split:\t:0}"
              status="{split:\t:1}"
              path="{}"
              echo -e "╭── Herdr Worktree: $branch ──────────────────────────"
              echo -e "│ Status: $status"
              echo -e "│ Path:   $path"
              echo -e "├── Git Status ────────────────────────────────────"
              git -C "$path" status --short 2>/dev/null || echo "Not a git directory"
              echo -e "├── Recent Commits ────────────────────────────────"
              git -C "$path" log --oneline -8 --color=always 2>/dev/null
              echo -e "╰──────────────────────────────────────────────────"
            ' '''

            [keybindings]
            enter = "actions:open"
            ctrl-e = "actions:edit"
            ctrl-t = "actions:open_terminal"
            ctrl-d = "actions:remove"
            ctrl-y = "actions:copy_path"

            [actions.open]
            description = "Open or switch to this worktree in Herdr"
            command = "herdr worktree open --path '{}' --focus"
            mode = "execute"

            [actions.edit]
            description = "Open worktree directory in editor"
            command = "''${EDITOR:-nvim} '{}'"
            mode = "execute"

            [actions.open_terminal]
            description = "Open new Ghostty terminal in worktree directory"
            command = "ghostty --working-directory='{}'"
            mode = "fork"

            [actions.remove]
            description = "Remove this worktree checkout"
            command = "herdr worktree remove --path '{}'"
            mode = "execute"

            [actions.copy_path]
            description = "Copy worktree path to clipboard"
            command = "echo -n '{}' | wl-copy"
            mode = "execute"
          '';
      };

    persistHome.directories = [
      ".local/share/herdr"
    ];
  };
}
