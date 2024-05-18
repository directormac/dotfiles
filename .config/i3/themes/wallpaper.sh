#!/usr/bin/env bash

## Copyright (C) 2020-2024 Aditya Shakya <adi1090x@gmail.com>
##
## Apply wallpaper on i3 startup

WALLPAPER='/home/artifex/.config/i3/themes/artifex/wallpaper'

## For single monitor
#hsetroot -root -cover "$WALLPAPER"

## For all monitors
hsetroot -cover "$WALLPAPER"
