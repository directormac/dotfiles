#!/usr/bin/env bash
# ==============================================================================
# custom-number.sh - Format window/pane indices in various numeral styles
# Inspired by and adapted from tokyo-night-tmux
# ==============================================================================

ID="${1:-1}"
FORMAT="${2:-kanji}"

format_hide=""
format_none="0123456789"
format_digital="🯰🯱🯲🯳🯴🯵🯶🯷🯸🯹"
format_fsquare="󰎡󰎤󰎧󰎪󰎭󰎱󰎳󰎶󰎹󰎼"
format_hsquare="󰎣󰎦󰎩󰎬󰎮󰎰󰎵󰎸󰎻󰎾"
format_dsquare="󰎢󰎥󰎨󰎫󰎲󰎯󰎴󰎷󰎺󰎽"
format_roman=" 󱂈󱂉󱂊󱂋󱂌󱂍󱂎󱂏󱂐"
format_super="⁰¹²³⁴⁵⁶⁷⁸⁹"
format_sub="₀₁₂₃₄₅₆₇₈₉"

kanji_map=("〇" "一" "二" "三" "四" "五" "六" "七" "八" "九" "十")

if [ "$FORMAT" = "hide" ]; then
  exit 0
fi

if [ "$FORMAT" = "kanji" ]; then
  if [[ "$ID" =~ ^[0-9]+$ ]] && [ "$ID" -ge 1 ] && [ "$ID" -le 10 ]; then
    echo -n "${kanji_map[$ID]}"
  else
    echo -n "$ID"
  fi
  exit 0
fi

# Retrieve selected format string
format="$(eval echo \"\$format_${FORMAT}\")"

if [ -z "$format" ]; then
  echo -n "$ID"
  exit 0
fi

if [ "$FORMAT" = "roman" ] && [ "${#ID}" -gt 1 ]; then
  echo -n "$ID"
else
  for ((i = 0; i < ${#ID}; i++)); do
    DIGIT="${ID:i:1}"
    echo -n "${format:DIGIT:1}"
  done
fi
