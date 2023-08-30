# Tmux Configuration
# Must not overide with neovim and wezterm
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix
#Reduce time to wait for Escape key. For Neovim
set -g escape-time 10
#Enable Mouse
set -g mouse on
#Clipboard
set -g set-clipboard on
#Enable colours enable neovim termguicolors and check shell with "echo $TERM"
set -g default-terminal 'xterm-256color'
set -as terminal-features ',xterm-256color:RGB'



#Set base index 1
set -g base-index 1 # index of tabs starts at 1
set -g pane-base-index 1 # inex of pane must also start at 1
set-window-option -g pane-base-index 1 # Base window number?
set-option -g renumber-windows on # Renumber windows on remove
#History Limit 50k lines
set -g history-limit 50000
#Set Refresh every Second
set-option -g status-interval 100
# Disable automatic renaming
set-option -g automatic-rename on
#dont exit from tmux when closing session
set -g detach-on-destroy off 

# Key bind section all key assignments below must use Prefix-key
# Prefix key is default <C-a>
#Vim style pane selection <Prefix-key>
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
# <Prefix-x>
bind-key x kill-pane
# <Prefix-k>
# bind-key k run-shell "tmux detach-client" \; run-shell "tmux kill-session" \; run-shell "clear"
# Split current window horizontally
# bind - split-window -v
# Split current window vertically
# bind | split-window -h
bind - split-window -v -c "#{pane_current_path}" #split to current path
bind = split-window -h -c "#{pane_current_path}" #split to current path

#Prefix key + r reload config
bind R source-file ~/.tmux.conf \; display "TMUX Configuration Reloaded!"

# Non prefixed key
# Shift Alt vim keys to switch windows
# bind -n M-H previous-window
# bind -n M-L next-window

# Prefix key + T
bind T clock-mode

# Set vi-mode
set-window-option -g mode-keys vi
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
    | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

bind-key -n C-2 if-shell "$is_vim" "send-keys C-2"
bind-key -n C-3 if-shell "$is_vim" "send-keys C-3"
bind-key -n C-k if-shell "$is_vim" "send-keys C-k"
bind-key -n C-l if-shell "$is_vim" "send-keys C-l"

# Navigation
#Use alt-keys to navigation

bind-key -n M-1 select-window -t :1
bind-key -n M-2 select-window -t :2
bind-key -n M-3 select-window -t :3
bind-key -n M-4 select-window -t :4
bind-key -n M-5 select-window -t :5
bind-key -n M-6 select-window -t :6
bind-key -n M-7 select-window -t :7
bind-key -n M-8 select-window -t :8
bind-key -n M-9 select-window -t :9
bind-key -n M-0 select-window -t :0
bind-key -n M-, select-window -t -1
bind-key -n M-. select-window -t +1

bind-key -n M-[ select-pane -t -1
bind-key -n M-] select-pane -t +1

bind -n M-Left select-pane -L
bind -n M-Right select-pane -D
bind -n M-Up select-pane -U
bind -n M-Down select-pane -R


# Tokyonight Storm

#!/usr/bin/env bash

# TokyoNight colors for Tmux

set -g mode-style "fg=#7aa2f7,bg=#3b4261"

set -g message-style "fg=#7aa2f7,bg=#3b4261"
set -g message-command-style "fg=#7aa2f7,bg=#3b4261"

set -g pane-border-style "fg=#3b4261"
set -g pane-active-border-style "fg=#7aa2f7"

set -g status "on"
set -g status-justify "left"

set -g status-style "fg=#7aa2f7,bg=#1f2335"

set -g status-left-length "100"
set -g status-right-length "100"

set -g status-left-style NONE
set -g status-right-style NONE

set -g status-left "#[fg=#1d202f,bg=#7aa2f7,bold]#[fg=#7aa2f7,bg=#1f2335,nobold,nounderscore,noitalics]"
set -g status-right "#[fg=#1f2335,bg=#1f2335,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#1f2335] #{prefix_highlight} #[fg=#3b4261,bg=#1f2335,nobold,nounderscore,noitalics]#[fg=#7aa2f7,bg=#3b4261] %Y-%m-%d  %H:%M #[fg=#7aa2f7,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#1d202f,bg=#7aa2f7,bold] #S | #h "

setw -g window-status-activity-style "underscore,fg=#a9b1d6,bg=#1f2335"
setw -g window-status-separator ""
setw -g window-status-style "NONE,fg=#a9b1d6,bg=#1f2335"
setw -g window-status-format "#[fg=#1f2335,bg=#1f2335,nobold,nounderscore,noitalics]#[default] #I #W #[fg=#1f2335,bg=#1f2335,nobold,nounderscore,noitalics]"
setw -g window-status-current-format "#[fg=#1f2335,bg=#3b4261,nobold,nounderscore,noitalics]#[fg=#3b4261,bg=#7aa2f7,bold]  #I  #[fg=#a9b1d6,bg=#3b4261,nobold,nounderscore,noitalics] #W "

# tmux-plugins/tmux-prefix-highlight support
set -g @prefix_highlight_output_prefix "#[fg=#e0af68]#[bg=#1f2335]#[fg=#1f2335]#[bg=#e0af68]"
set -g @prefix_highlight_output_suffix ""

#Plugins Install <Prefix-I> to Install
set -g @plugin 'tmux-plugins/tmux-sensible' #sensible commands
set -g @plugin 'tmux-plugins/tmux-resurrect' # resurrect sessions
set -g @plugin 'tmux-plugins/tmux-continuum' #works with resurrreect
set -g @plugin 'tmux-plugins/tmux-open' #open links and files in copy mode
set -g @plugin 'tmux-plugins/tmux-pain-control' # manage panes and windowsss

set -g @plugin 'jimeh/tmuxifier' #tmux persistent layouts

# <Perfix-t> or t anywhere on shell, shows all directory and creates new session
set -g @plugin '27medkamal/tmux-session-wizard'

set -g @session-wizard 't'


# Resource TMUX Plugins
run '~/.tmux/plugins/tpm/tpm'
