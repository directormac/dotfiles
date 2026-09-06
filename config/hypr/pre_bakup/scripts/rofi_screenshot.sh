#!/usr/bin/env bash

# Use colors from rofi if possible, otherwise defaults
background="#1e1e2e" 
accent="#89b4fa"

# Try to get colors from rofi mini theme
if [ -f "$HOME/.config/rofi/mini.rasi" ]; then
    background=$(grep 'background:' "$HOME/.config/rofi/mini.rasi" | cut -d':' -f2 | tr -d ' ;' | head -n1)
    accent=$(grep 'selected:' "$HOME/.config/rofi/mini.rasi" | cut -d':' -f2 | tr -d ' ;' | head -n1)
fi

# Import Current Theme
RASI="$HOME/.config/rofi/screenshot.rasi"
prompt='Screenshot'
mesg="Directory :: $(xdg-user-dir PICTURES)/Screenshots"

# Options
layout=$(grep 'USE_ICON' "${RASI}" | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
  option_1="󰡊 Capture Area"
  option_2=" Capture Desktop"
  option_3="󰞣 Capture Window"
  option_4="󰻜 Capture in 5s"
else
  option_1="󰡊"
  option_2=""
  option_3="󰞣"
  option_4="󰻜"
fi

ROFI_FOCUSED="$HOME/.config/hypr/scripts/rofi_focused"
SCREENSHOT_SCRIPT="$HOME/.config/hypr/scripts/screenshot.sh"

# Rofi CMD
rofi_cmd() {
  "$ROFI_FOCUSED" -dmenu \
    -p "$prompt" \
    -mesg "$mesg" \
    -markup-rows \
    -theme "${RASI}"
}

# Pass variables to rofi dmenu
run_rofi() {
  echo -e "$option_1\n$option_2\n$option_3\n$option_4" | rofi_cmd
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
  "$option_1") "$SCREENSHOT_SCRIPT" --area ;;
  "$option_2") "$SCREENSHOT_SCRIPT" --now ;;
  "$option_3") "$SCREENSHOT_SCRIPT" --win ;;
  "$option_4") "$SCREENSHOT_SCRIPT" --in5 ;;
esac
