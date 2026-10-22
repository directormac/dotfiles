#!/usr/bin/env bash
# ==============================================================================
# update-pane-border-status.sh - Control pane-border-status visibility
#
# Only shows pane status border when there are 2 or more non-sidebar panes
# in the target window. Workmux sidebar panes are ignored so opening a sidebar
# does not cause the pane title border to appear.
# ==============================================================================

WINDOW="${1:-}"

if [ -z "$WINDOW" ]; then
  WINDOW="$(tmux display-message -p '#{window_id}' 2>/dev/null || true)"
fi

if [ -z "$WINDOW" ]; then
  exit 0
fi

# Count non-sidebar panes in target window
count="$(tmux list-panes -t "$WINDOW" -F '#{@workmux_role}' 2>/dev/null | grep -vc '^sidebar$' || true)"

if [ "$count" -gt 1 ]; then
  tmux set-option -w -t "$WINDOW" pane-border-status bottom
else
  tmux set-option -w -t "$WINDOW" pane-border-status off
fi
