# Tmux Core Configuration
#
# Holds the `programs.tmux` options and the main `tmux.conf` body.
#
# The `tmux.conf` body is tagged with the `# tmux` comment. Neovim resolves
# that tag through its treesitter injection query, so the block is parsed
# with the tmux grammar instead of shell. Without the tag `conform`'s
# `injected` formatter would hand the tmux configuration to `shfmt`, which
# cannot parse tmux's own syntax (`#{...}` formats, `set -g @option "value"`,
# `bind -N "name" ...`, ...).
{
  pkgs,
  resurrectRestoreScript,
  resurrectSaveScript,
  tmuxPkg,
  windowIcon,
  ...
}:
let
  # Bound to a plain name so that the generated configuration only contains a
  # regular parameter expansion. Interpolating the store path inline would
  # leave `${pkgs.tmuxPlugins.…}` in the tmux configuration, which is not
  # valid shell syntax and breaks the `injected` formatter.
  continuumScript = "${pkgs.tmuxPlugins.continuum}/share/tmux-plugins/continuum/continuum.tmux";
in
{
  enable = true;
  package = tmuxPkg;
  aggressiveResize = true;
  baseIndex = 1;
  clock24 = true;
  customPaneNavigationAndResize = true;
  escapeTime = 100;

  extraConfig =
    # tmux
    ''
      # General Settings
      set -g status-interval 1
      set -g history-limit 100000
      set -g repeat-time 350
      set -g display-time 1500
      set -s set-clipboard on
      set -g renumber-windows on
      set -g detach-on-destroy off
      set -g wrap-search off
      set -g allow-passthrough all
      set -g visual-activity off

      # Terminal
      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",*256col*:Tc"
      set -ga terminal-overrides ",xterm-ghostty:Tc"
      set -as terminal-features ",xterm-ghostty:RGB"
      set -as terminal-features ",xterm-256color:RGB"

      # Extended keys
      set -s extended-keys on
      set -as terminal-features "xterm*:extkeys"

      # Bindings
      bind -N "Prompt a command" : command-prompt -P
      bind -N "Fuzzy search Tmux keybindings" ? display-popup -E -w 80% -h 75% -d "#{pane_current_path}" -T "Tmux Keybindings" "tmux list-keys -N -a | tv --layout portrait --hide-preview --input-position bottom"
      bind -N "Television sesh" "s" display-popup -E -w 80% -h 70% -d '#{pane_current_path}' -T 'Sesh' "tv sesh --hide-preview --hide-status-bar --input-position bottom"
      bind -N "Jump to urgent window or toggle last window" ` if-shell -F "#{session_alerts}" "next-window -a" "last-window"
      bind -N "Reload Configuration" R source-file "~/.config/tmux/tmux.conf" \; display "Nix-managed tmux config reloaded!"
      bind -N "Copy selection" -T copy-mode-vi y send -X copy-pipe-and-cancel "wl-copy"
      bind -N "Create window" c new-window -c "#{pane_current_path}"
      bind -N "Create window cwd" C new-window
      bind -N "Display Clock" C-t clock-mode
      bind -N "Kill pane" x kill-pane
      bind -N "Kill window" q confirm-before -p "Kill window #W? (y/n)" kill-window
      bind -N "Kill session" X confirm-before -p "Kill session #S? (y/n)" kill-session
      bind -N "Split pane vertically" - split-window -v -c "#{pane_current_path}"
      bind -N "Split pane horizontally" \| split-window -h -c "#{pane_current_path}"

      bind -N "Begin selection" -T copy-mode-vi v send-keys -X begin-selection
      bind -N "Copy selection"  -T copy-mode-vi y send-keys -X copy-selection-and-cancel

      # Advanced Pane Movements & Inspection
      bind -N "Break pane to background window" B break-pane -d
      bind -N "Toggle marked pane" m select-pane -m
      bind -N "Join marked pane here" J join-pane
      bind -N "Inspect scrollback in Neovim" E display-popup -w 95% -h 90% -E "tmux capture-pane -p -S -3000 | nvim -c 'set buftype=nofile' -"
      bind -N "Respawn failed pane" r respawn-pane -k
      bind -N "Toggle synchronize panes" S set-window-option synchronize-panes

      # Unbind alt key, bound in neovim buffers.
      unbind-key -n M-0
      unbind-key -n M-1
      unbind-key -n M-2
      unbind-key -n M-3
      unbind-key -n M-4
      unbind-key -n M-5
      unbind-key -n M-6
      unbind-key -n M-7
      unbind-key -n M-8
      unbind-key -n M-9

      bind -N "Go to window 1" -T root C-1 select-window -t 1
      bind -N "Go to window 2" -T root C-2 select-window -t 2
      bind -N "Go to window 3" -T root C-3 select-window -t 3
      bind -N "Go to window 4" -T root C-4 select-window -t 4
      bind -N "Go to window 5" -T root C-5 select-window -t 5
      bind -N "Go to window 6" -T root C-6 select-window -t 6
      bind -N "Go to window 7" -T root C-7 select-window -t 7
      bind -N "Go to window 8" -T root C-8 select-window -t 8
      bind -N "Go to window 9" -T root C-9 select-window -t 9

      # Error Preservation & History
      set -g history-file "~/.local/state/tmux/tmux_history"
      set -g remain-on-exit 'failed'
      set-hook -gw pane-died 'display-message "⚠️ Pane #{hook_pane} exited with failure! Press any key to close, or Prefix + r to respawn."'
      set-hook -g session-window-changed 'run-shell -b "tmux set-option -q -u -w -t \"#{hook_old_window}\" synchronize-panes"'

      # Keep tmux server alive without open sessions so systemd service stays running
      # and continuum auto-restore has time to restore sessions on boot
      set -s exit-empty off

      # Wire resurrect and continuum through the lock-protected, self-healing wrappers.
      set -g @resurrect-save-script-path "${resurrectSaveScript}"
      set -g @resurrect-restore-script-path "${resurrectRestoreScript}"
      bind -N "Save tmux session (resurrect)" C-S run-shell "${resurrectSaveScript}"
      bind -N "Restore tmux session (resurrect)" C-R run-shell "${resurrectRestoreScript} manual"

      # Save on client detach as well as on the periodic continuum interval.
      # `-g` (not `-ga`) so that re-sourcing tmux.conf does not stack duplicate hooks.
      set-hook -g client-detached "run-shell -b '${resurrectSaveScript} quiet'"

      set -g @window_icon "${windowIcon}"

      set-environment -g COLLIE_MUX "tmux"

      # The status bar is sourced before continuum runs, so that continuum can
      # prepend its auto-save interpolation to the final `status-right`.
      #
      # `run-shell` blocks the rest of the configuration until the command
      # returns, and Home Manager appends the plugin blocks *before*
      # `extraConfig`. Loading continuum from a plugin block would therefore
      # happen before `status.tmux.conf` is sourced, and the interpolation
      # would be wiped by it. Running it here keeps the status bar intact and
      # makes sure `continuum_restore.sh` is spawned exactly once.
      source -F "$HOME/.config/tmux/status.tmux.conf"
      set -g @continuum-save-interval "5"
      set -g @continuum-restore "on"
      run-shell "${continuumScript}"
    '';

  focusEvents = true;
  historyLimit = 1000000;
  keyMode = "vi";
  mouse = true;
  prefix = "C-a";
  shortcut = "a";
  terminal = "tmux-256color";
}
