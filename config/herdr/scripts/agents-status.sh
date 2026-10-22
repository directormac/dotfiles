#!/usr/bin/env bash
# ==============================================================================
# agents-status.sh - Herdr tab bar right status indicator for AI agents
# ==============================================================================
set -euo pipefail

if ! command -v herdr >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

herdr agent list 2>/dev/null | jq -r '
  .result.agents // [] |
  length as $total |
  if $total == 0 then
    "󰚩 0"
  else
    (map(select(.agent_status == "working")) | length) as $w |
    (map(select(.agent_status == "blocked" or .agent_status == "waiting")) | length) as $b |
    if $b > 0 and $w > 0 then
      "󰚩 \($w)/\($total) 󱐋 · 󰀦 \($b)"
    elif $w > 0 then
      "󰚩 \($w)/\($total) 󱐋"
    elif $b > 0 then
      "󰚩 \($total) · 󰀦 \($b) waiting"
    else
      "󰚩 \($total) idle"
    end
  end
' 2>/dev/null || true
