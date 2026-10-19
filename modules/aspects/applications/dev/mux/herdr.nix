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
        ...
      }:
      let
        herdrPkg =
          inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.herdr
            or (pkgs.writeShellScriptBin "herdr" "echo herdr");

        tv-herdr-agent-preview = pkgs.writeShellScript "tv-herdr-agent-preview" ''
          agent="$1"
          status="$2"
          pane="$3"
          cwd="$4"
          title="$5"

          echo "agent: $agent"
          echo "status: $status | pane: $pane"
          [ -n "$cwd" ] && echo "cwd: $cwd"
          [ -n "$title" ] && echo "title: $title"
          echo ""
          echo "recent output"
          ${herdrPkg}/bin/herdr agent read "$agent" --lines 15 2>/dev/null || \
            ${herdrPkg}/bin/herdr pane read "$pane" --lines 15 2>/dev/null || echo "(no output)"
        '';

        tv-herdr-session-preview = pkgs.writeShellScript "tv-herdr-session-preview" ''
          name="$1"
          sess=$(${herdrPkg}/bin/herdr session list --json 2>/dev/null | ${pkgs.jq}/bin/jq -r --arg n "$name" '.sessions[]? | select(.name == $n)')
          running=$(echo "$sess" | ${pkgs.jq}/bin/jq -r '.running // false')
          dir=$(echo "$sess" | ${pkgs.jq}/bin/jq -r '.session_dir // ""')
          sock=$(echo "$sess" | ${pkgs.jq}/bin/jq -r '.socket_path // ""')

          echo "$name"
          if [ "$running" = "true" ]; then
            echo "🟢 Running"
          else
            echo "⚪ Stopped"
          fi
          [ -n "$dir" ] && echo "directory: $dir"
          [ -n "$sock" ] && echo "socket: $sock"

          if [ "$running" = "true" ]; then
            wss=$(${herdrPkg}/bin/herdr --session "$name" workspace list 2>/dev/null | ${pkgs.jq}/bin/jq -r '.result.workspaces[]? | "  [\(.workspace_id)] \(.label) (tabs: \(.tab_count), panes: \(.pane_count), agent: \(.agent_status))"')
            if [ -n "$wss" ]; then
              echo ""
              echo "workspaces"
              echo "$wss"
            fi
            tabs=$(${herdrPkg}/bin/herdr --session "$name" tab list 2>/dev/null | ${pkgs.jq}/bin/jq -r '.result.tabs[]? | "  [\(.tab_id)] \(.label) (panes: \(.pane_count))"')
            if [ -n "$tabs" ]; then
              echo ""
              echo "tabs"
              echo "$tabs"
            fi
          fi
        '';

        tv-herdr-workspace-preview = pkgs.writeShellScript "tv-herdr-workspace-preview" ''
          ws="$1"
          info=$(${herdrPkg}/bin/herdr workspace get "$ws" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.result.workspace')
          label=$(echo "$info" | ${pkgs.jq}/bin/jq -r '.label // ""')
          focused=$(echo "$info" | ${pkgs.jq}/bin/jq -r '.focused // false')
          worktree=$(echo "$info" | ${pkgs.jq}/bin/jq -r '.worktree.checkout_path // "None"')

          echo "workspace $ws"
          [ -n "$label" ] && echo "label: $label"
          echo "focused: $focused"
          echo "worktree: $worktree"

          tabs=$(${herdrPkg}/bin/herdr tab list --workspace "$ws" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.result.tabs[]? | "  [\(.tab_id)] \(.label) (tabs: \(.tab_count // 0), panes: \(.pane_count), agent: \(.agent_status))"')
          if [ -n "$tabs" ]; then
            echo ""
            echo "tabs"
            echo "$tabs"
          fi

          panes=$(${herdrPkg}/bin/herdr pane list --workspace "$ws" 2>/dev/null | ${pkgs.jq}/bin/jq -r '.result.panes[]? | "  [\(.pane_id)] \(.label) (agent: \(.agent // "none"), cwd: \(.cwd))"')
          if [ -n "$panes" ]; then
            echo ""
            echo "panes & agents"
            echo "$panes"
          fi
        '';

        tv-herdr-worktree-preview = pkgs.writeShellScript "tv-herdr-worktree-preview" ''
          branch="$1"
          status="$2"
          path="$3"

          echo "worktree: $branch"
          echo "status: $status"
          echo "path: $path"
          echo ""
          echo "git status"
          ${pkgs.git}/bin/git -C "$path" status --short 2>/dev/null || echo "Not a git directory"
          echo ""
          echo "recent commits"
          ${pkgs.git}/bin/git -C "$path" log --oneline -5 --color=always 2>/dev/null || true
        '';
      in
      {
        home.file.".config/herdr/config.toml".source = config.lib.dots.link "herdr/config.toml";
        home.packages = [ herdrPkg ];

        systemd.user.services.herdr-server = {
          Install.WantedBy = [ "graphical-session.target" ];

          Service = {
            ExecStart = "${herdrPkg}/bin/herdr server";
            KillMode = "mixed";
            Restart = "on-failure";
            Type = "simple";
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
            command = "${tv-herdr-agent-preview} '{split:\t:0}' '{split:\t:1}' '{split:\t:4}' '{split:\t:5}' '{split:\t:6}'"

            [keybindings]
            enter = "actions:focus"
            ctrl-d = "actions:interrupt"
            ctrl-y = "actions:copy_agent"
            [actions.focus]
            description = "Focus pane running this agent"
            command = "herdr pane focus '{split:\t:4}'"
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
            command = "${tv-herdr-session-preview} '{split:\t:1}'"

            [keybindings]
            enter = "actions:attach"
            ctrl-d = "actions:delete"
            ctrl-y = "actions:copy_name"

            [actions.attach]
            description = "Attach to this Herdr session"
            command = "herdr session attach '{split:\t:1}'"
            mode = "execute"

            [actions.open_terminal]
            description = "Open session attach in a new Ghostty terminal window"
            command = "ghostty -e herdr session attach '{split:\t:1}'"
            mode = "fork"

            [actions.stop]
            description = "Stop this running session"
            command = "herdr session stop '{split:\t:1}'"
            mode = "execute"

            [actions.delete]
            description = "Delete this session"
            command = "herdr session delete '{split:\t:1}'"
            mode = "execute"

            [actions.copy_name]
            description = "Copy session name to clipboard"
            command = "echo -n '{split:\t:1}' | wl-copy"
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
            command = "${tv-herdr-workspace-preview} '{split:\t:0}'"

            [keybindings]
            enter = "actions:focus"
            ctrl-d = "actions:close"
            ctrl-y = "actions:copy_id"
            [actions.focus]
            description = "Focus this Herdr workspace"
            command = "herdr workspace focus '{split:\t:0}'"
            mode = "execute"

            [actions.close]
            description = "Close this Herdr workspace"
            command = "herdr workspace close '{split:\t:0}'"
            mode = "execute"

            [actions.copy_id]
            description = "Copy workspace ID to clipboard"
            command = "echo -n '{split:\t:0}' | wl-copy"
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
            command = "${tv-herdr-worktree-preview} '{split:\t:0}' '{split:\t:1}' '{split:\t:2}'"

            [keybindings]
            enter = "actions:open"
            ctrl-e = "actions:edit"
            ctrl-d = "actions:remove"
            ctrl-y = "actions:copy_path"
            [actions.open]
            description = "Open or switch to this worktree in Herdr"
            command = "herdr worktree open --path '{split:\t:2}' --focus"
            mode = "execute"

            [actions.edit]
            description = "Open worktree directory in editor"
            command = "''${EDITOR:-nvim} '{split:\t:2}'"
            mode = "execute"

            [actions.open_terminal]
            description = "Open new Ghostty terminal in worktree directory"
            command = "ghostty --working-directory='{split:\t:2}'"
            mode = "fork"

            [actions.remove]
            description = "Remove this worktree checkout"
            command = "herdr worktree remove --path '{split:\t:2}'"
            mode = "execute"

            [actions.copy_path]
            description = "Copy worktree path to clipboard"
            command = "echo -n '{split:\t:2}' | wl-copy"
            mode = "execute"
          '';
      };

    persistHome.directories = [
      ".config/herdr"
      ".local/share/herdr"
      ".local/state/herdr"
    ];
  };
}
