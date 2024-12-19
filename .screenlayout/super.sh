#!/bin/bash
xrandr --output DisplayPort-0 --primary --mode 2560x1440 --rate 165 --pos 0x0 --rotate normal
xrandr --output DisplayPort-1 --mode 2560x1440 --rate 144 --pos 2560x0 --rotate normal
# --output HDMI-A-0 --off --output HDMI-A-1 --off --output DP3 --off --output HDMI3 --off --output HDMI4 --off --output VIRTUAL1 --off
archcraft-reload-theme
