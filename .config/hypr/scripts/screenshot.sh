#!/usr/bin/env bash

# Use colors from rofi if possible, otherwise defaults
background="#1e1e2e" 
accent="#89b4fa"

# Try to get colors from rofi mini theme
if [ -f "$HOME/.config/rofi/mini.rasi" ]; then
    background=$(grep 'background:' "$HOME/.config/rofi/mini.rasi" | cut -d':' -f2 | tr -d ' ;' | head -n1)
    accent=$(grep 'selected:' "$HOME/.config/rofi/mini.rasi" | cut -d':' -f2 | tr -d ' ;' | head -n1)
fi

time=$(date +%Y-%m-%d-%H-%M-%S)
dir="$(xdg-user-dir PICTURES)/Screenshots"
file="Screenshot_${time}.png"

iDIR="$HOME/.config/swaync/icons"
notify_cmd_shot="notify-send -h string:x-canonical-private-synchronous:sys-notify-shot -u low -i ${iDIR}/picture.png"

notify_view() {
  # Always copy to clipboard automatically
  if [[ -f "${dir}/${file}" ]]; then
    wl-copy < "${dir}/${file}"
    ${notify_cmd_shot} "Copied to clipboard."
  fi

  paplay /usr/share/sounds/freedesktop/stereo/screen-capture.oga &>/dev/null &
  
  if command -v satty &> /dev/null; then
    # Run satty for optional annotation, but don't block the notification logic
    satty -f "${dir}/${file}" -o "${dir}/${file}" --copy-command "wl-copy"
  fi

  if [[ -e "$dir/$file" ]]; then
    ${notify_cmd_shot} "Screenshot Saved."
  else
    ${notify_cmd_shot} "Screenshot Deleted."
  fi
}

countdown() {
  for sec in $(seq $1 -1 1); do
    notify-send -h string:x-canonical-private-synchronous:sys-notify-count -t 1000 -i "$iDIR"/timer.png "Taking shot in : $sec"
    sleep 1
  done
}

shotnow() {
  mkdir -p "${dir}"
  cd "${dir}" && sleep 0.5 && grim "${file}"
  notify_view
}

shot5() {
  countdown '5'
  mkdir -p "${dir}"
  sleep 1 && cd "${dir}" && grim "${file}"
  notify_view
}

shot10() {
  countdown '10'
  mkdir -p "${dir}"
  sleep 1 && cd "${dir}" && grim "${file}"
  notify_view
}

shotwin() {
  mkdir -p "${dir}"
  # Check for Hyprland or Sway
  if [[ "$XDG_CURRENT_DESKTOP" == "Hyprland" ]]; then
    geometry=$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')
  elif [[ "$XDG_CURRENT_DESKTOP" == "sway" ]] || [[ -n "$SWAYSOCK" ]]; then
    geometry=$(swaymsg -t get_tree | jq -r '.. | select(.focused? == true) | .rect | "\(.x),\(.y) \(.width)x\(.height)"')
  else
    # Fallback to slurp if we can't detect window manager
    geometry=$(slurp)
  fi
  
  if [[ -n "$geometry" ]]; then
    cd "${dir}" && grim -g "${geometry}" "${file}"
    notify_view
  else
    exit 1
  fi
}

shotarea() {
  mkdir -p "${dir}"
  # Slurp for area selection
  area=$(slurp -b "${background:1}CC" -c "${accent:1}ff" -s "${accent:1}0D" -w 2)
  if [ -z "$area" ]; then exit 1; fi
  cd "${dir}" && grim -g "$area" "${file}"
  notify_view
}

if [[ "$1" == "--now" ]]; then
  shotnow
elif [[ "$1" == "--win" ]]; then
  shotwin
elif [[ "$1" == "--area" ]]; then
  shotarea
elif [[ "$1" == "--in5" ]]; then
  shot5
elif [[ "$1" == "--in10" ]]; then
  shot10
else
  echo -e "Available Options : --now --win --area --in5 --in10"
fi

exit 0
