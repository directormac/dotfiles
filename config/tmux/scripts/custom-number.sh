#!/usr/bin/env bash
# ==============================================================================
# custom-number.sh - Format window/pane indices in various numeral styles
# Inspired by and adapted from tokyo-night-tmux
# ==============================================================================

# Number maps for indices 0 through 10
kanji_map=("〇" "一" "二" "三" "四" "五" "六" "七" "八" "九" "十")
circle_map=("🄋" "①" "②" "③" "④" "⑤" "⑥" "⑦" "⑧" "⑨" "⑩")
circle_black_map=("⓿" "❶" "❷" "❸" "❹" "❺" "❻" "❼" "❽" "❾" "❿")
digital_map=("🯰" "🯱" "🯲" "🯳" "🯴" "🯵" "🯶" "🯷" "🯸" "🯹" "🯱🯰")
fsquare_map=("󰎡" "󰎤" "󰎧" "󰎪" "󰎭" "󰎱" "󰎳" "󰎶" "󰎹" "󰎼" "󰎤󰎡")
hsquare_map=("󰎣" "󰎦" "󰎩" "󰎬" "󰎮" "󰎰" "󰎵" "󰎸" "󰎻" "󰎾" "󰎦󰎣")
dsquare_map=("󰎢" "󰎥" "󰎨" "󰎫" "󰎲" "󰎯" "󰎴" "󰎷" "󰎺" "󰎽" "󰎥󰎢")
roman_map=(" " "󱂈" "󱂉" "󱂊" "󱂋" "󱂌" "󱂍" "󱂎" "󱂏" "󱂐" "󱂐")
roman_text_map=("0" "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X")
super_map=("⁰" "¹" "²" "³" "⁴" "⁵" "⁶" "⁷" "⁸" "⁹" "¹⁰")
sub_map=("₀" "₁" "₂" "₃" "₄" "₅" "₆" "₇" "₈" "₉" "₁₀")
braille_map=("⠀" "⠁" "⠃" "⠇" "⠏" "⠟" "⠿" "⡿" "⣿" "⣶" "⠁⠀")

available_formats=(
  "kanji"
  "circle"
  "circle_black"
  "digital"
  "fsquare"
  "hsquare"
  "dsquare"
  "roman"
  "roman_text"
  "super"
  "sub"
  "braille"
)

pick_random_format() {
  local num_formats=${#available_formats[@]}
  local rand_idx=$((RANDOM % num_formats))
  echo "${available_formats[$rand_idx]}"
}

format_digit() {
  local id="$1"
  local fmt="$2"

  if [ "$fmt" = "hide" ]; then
    return 0
  fi

  if [ "$fmt" = "none" ]; then
    echo -n "$id"
    return 0
  fi

  if [[ $id =~ ^[0-9]+$ ]] && [ "$id" -ge 0 ] && [ "$id" -le 10 ]; then
    local var_name="${fmt}_map[$id]"
    local val="${!var_name}"
    if [ -n "$val" ]; then
      echo -n "$val"
      return 0
    fi
  fi

  echo -n "$id"
}

build_tmux_format() {
  local fmt="$1"
  if [ -z "$fmt" ] || [ "$fmt" = "random" ]; then
    fmt="$(pick_random_format)"
  fi

  # Build conditional format: #{?#{==:#I,1},<1>,#{?#{==:#I,2},<2>,...#I}}
  local result="#I"
  for i in {10..1}; do
    local formatted
    formatted="$(format_digit "$i" "$fmt")"
    result="#{?#{==:#I,$i},$formatted,$result}"
  done

  # Record chosen format and style in tmux options if tmux is active
  if command -v tmux >/dev/null 2>&1; then
    tmux set-option -g @window_number_style "$fmt" 2>/dev/null || true
    tmux set-option -g @window_number_format "$result" 2>/dev/null || true
  fi

  echo -n "$result"
}

# Subcommand handling
case "${1:-}" in
--list | list)
  printf "%s\n" "${available_formats[@]}"
  exit 0
  ;;
--randomize | randomize)
  chosen="$(pick_random_format)"
  build_tmux_format "$chosen" >/dev/null
  exit 0
  ;;
--tmux-format | tmux-format)
  target_fmt="${2:-random}"
  build_tmux_format "$target_fmt"
  echo ""
  exit 0
  ;;
esac

ID="${1:-1}"
FORMAT="${2:-random}"

if [ "$FORMAT" = "random" ]; then
  FORMAT="$(pick_random_format)"
fi

format_digit "$ID" "$FORMAT"
