#!/usr/bin/env bash

# WALLPAPER='/home/mac/.config/i3/themes/artifex/wallpaper'

## For single monitor
#hsetroot -root -cover "$WALLPAPER"

## For all monitors
# hsetroot -cover "$WALLPAPER"

# Span wallpaper accross monitors
feh --no-fehbg --randomize --no-xinerama --bg-scale '/home/mac/.wallpapers/'

## Random wallpaper on monitors
# feh --no-fehbg --randomize --bg-scale '/home/artifex/.wallpapers/'
