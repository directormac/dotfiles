#!/usr/bin/env zsh

#=============================================================#
# Zsh Configuration Files
# https://zsh.sourceforge.io/Intro/intro_3.html
#
# Zsh has several system-wide and user-local configuration files.
#
# System-wide configuration files are installation-dependent but are installed in /etc by default.
#
# User-local configuration files have the same name as their global counterparts but are prefixed with a dot (hidden). Zsh looks for these files in the path stored in the $ZDOTDIR environmental variable. However, if said variable is not defined, Zsh will use the user's home directory.
# File Descriptions
#
# The configuration files are read in the following order:
#
#     /etc/zshenv
#     ~/.zshenv
#     /etc/zprofile
#     ~/.zprofile
#     /etc/zshrc
#     ~/.zshrc
#     /etc/zlogin
#     ~/.zlogin
#     ~/.zlogout
#     /etc/zlogout
#
# zshenv
#
# This file is sourced by all instances of Zsh, and thus, it should be kept as small as possible and should only define environment variables.
# zprofile
# This file is similar to zlogin, but it is sourced before zshrc. It was added for KornShell fans. See the description of zlogin bellow for what it may contain.
#
# zprofile and zlogin are not meant to be used concurrently but can be done so.
#
# zshrc
# This file is sourced by interactive shells. It should define aliases, functions, shell options, and key bindings.
#
# zlogin
# This file is sourced by login shells after zshrc, and thus, it should contain commands that need to execute at login. It is usually used for messages such as fortune, msgs, or for the creation of files.
# This is not the file to define aliases, functions, shell options, and key bindings. It should not change the shell environment.
#
# zlogout
# This file is sourced by login shells during logout. It should be used for displaying messages and the deletion of files.

# This is loaded universally for all types of shell sessions
# (interactive or non-interactive, login or non-login).
# It is the only configuration file that gets loaded for non-interactive
# and non-login scripts like cron jobs. However,
# macOS overrides this for PATH settings for interactive shells.
# This is universally loaded, so you could use it to configure the shell for automated processes like cron jobs.
# However, it is best to explicitly set up environmental variables for automated processes
# in scripts and leave nothing to chance. As a beginner,
# you will not use this configuration file. In fact, few experienced macOS developers use it.
##
# Defines environment variables.
#
# # If not running interactively, don't do anything
# [[ $- != *i* ]] && return
#=============================================================#

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"
export XDG_CACHE_HOME="$HOME/.cache"
export ZDOTDIR="$HOME"

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

export LIBVIRT_DEFAULT_URI="qemu:///system"

export PATH=$HOME/.local/bin:$PATH

export PATH=$HOME/.cargo/bin:$PATH # cargo bins

typeset -U path PATH # auto-dedupe

path=(
  $HOME/.local/bin
  $HOME/bin
  /usr/local/bin
  /usr/bin
  /usr/sbin
  /bin
  $HOME/.cargo/bin:$PATH
  $path
)

export PATH
