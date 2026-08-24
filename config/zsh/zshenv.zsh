#!/usr/bin/env zsh

#=============================================================#
# .zshenv 	Contains exported environment variables
# .zprofile 	Contains environment variables and shell-specific options
# .zshrc 	Contains settings for interactive shell
# .zlogin 	Contains instructions to execute on session login
# .zlogout 	Contains instructions to execute on session logout

# This is loaded universally for all types of shell sessions
# (interactive or non-interactive, login or non-login).
# It is the only configuration file that gets loaded for non-interactive
# and non-login scripts like cron jobs. However,
# macOS overrides this for PATH settings for interactive shells.
# This is universally loaded, so you could use it to configure the shell for automated processes like cron jobs.
# However, it is best to explicitly set up environmental variables for automated processes
# in scripts and leave nothing to chance. As a beginner,
# you will not use this configuration file. In fact, few experienced macOS developers use it.

# # If not running interactively, don't do anything
# [[ $- != *i* ]] && return
#=============================================================#

export TZ="Asia/Manila"
export BROWSER="/usr/sbin/zen-browser" # set google chrome as default browser
export EDITOR="nvim"                   # set neovim as default editor
export KEYTIMEOUT=30
export TERMINAL="/usr/sbin/ghostty"

export DOTFILES="$HOME/.dotfiles/" # dotfiles path

export DOTSDIR="$HOME/.dotfiles/"           # dotfiles path
export DOTSZSH="$HOME/.dotfiles/config/zsh" # dotfiles zsh config path

export GPG_TTY=$(tty)
export SSH_AUTH_SOCK="$(gpgconf --list-dirs agent-ssh-socket)"

if ((${+commands[vivid]})); then
  export LS_COLORS="$(vivid generate catppuccin-mocha)"
else
  export LS_COLORS=':tw=01;34:ow=01;34:st=01;34'
fi

# Needed for tauri dev mode
export WEBKIT_DISABLE_COMPOSITING_MODE=1
export WEBKIT_DISABLE_DMABUF_RENDERER=1

## Setting environment variables for wayland session
export XDG_SESSION_TYPE=wayland
export XDG_SESSION_DESKTOP=sway
export XDG_CURRENT_DESKTOP=sway
export XDG_CURRENT_SESSION=sway

## GTK environment
export TDESKTOP_DISABLE_GTK_INTEGRATION=1
export CLUTTER_BACKEND=wayland
export GDK_BACKEND="wayland,x11"
export NO_AT_BRIDGE=1
export WINIT_UNIX_BACKEND=wayland
# export DBUS_SESSION_BUS_ADDRESS
# export DBUS_SESSION_BUS_PID

export _ZO_EXCLUDE_DIRS="$HOME:$HOME/Resources/*:$HOME/Downloads/*:$HOME/Music:$HOME/Videos/*:$HOME/Downloads/*:$HOME/Pictures/*:$HOME/Documents/*:/tmp:/var:/proc:/sys:/deps:/_build:/node_modules/:/.git"

## Firefox
export MOZ_ENABLE_WAYLAND=1

## Qt environment
export QT_QPA_PLATFORM=xcb
export QT_QPA_PLATFORMTHEME=qt5ct
export QT_AUTO_SCREEN_SCALE_FACTOR=1
# export QT_QPA_PLATFORM=wayland-egl #error with apps xcb
#export QT_WAYLAND_FORCE_DPI=physical #uncomment this to use monitor's DPI
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1

## Elementary environment
export ELM_DISPLAY=wl
export ECORE_EVAS_ENGINE=wayland_egl
export ELM_ENGINE=wayland_egl
export ELM_ACCEL=opengl
# export ELM_SCALE=1

export MISE_EXPERIMENTAL=1

## SDL environment
export SDL_VIDEODRIVER=wayland

## Java environment
export _JAVA_AWT_WM_NONREPARENTING=1

# LibreOffice
export SAL_USE_VCLPLUGIN=gtk3

export PATH=$HOME/.local/bin:$PATH

export PATH=$HOME/.cargo/bin:$PATH # cargo bins

typeset -U path PATH # auto-dedupe

path=(
  "$PATH"
  $path
)

export PATH
