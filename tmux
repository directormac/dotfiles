#command delay shortener
set -g escape-time 10 

#Enable Mouse
set -g mouse on

#Clipboard
set -g set-clipboard on

#Reduce time to wait for Escape key. For Neovim
set-option escape-time 40

#Bind <Ctrl-a> as prefix2
set-option -g prefix2 C-a

#enable colours
set -s default-terminal 'tmux-256color'
set-option -ga terminal-overrides ",xterm-256Color:Tc"

#Set base index 1
set -g base-index 1
set -g pane-base-index 1
set-window-option -g pane-base-index 1
set-option -g renumber-windows on

#Vim style pane selection <Prefix-key>
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

#Use alt-arrow keys without prefix key to switch panes
bind -n M-Left select-pane -L
bind -n M-Right select-pane -D
bind -n M-Up select-pane -U
bind -n M-Down select-pane -R

#History Limit 50k lines
set -g history-limit 50000

#STATUS BAR SECTION

#Set status bar color
# set-option -g status-style bg=default #transparent statusbar
#Justify statusbar center
# set -g status-justify centre
#LEFT SIDE
# set-option -g status-left '#{session_name}'
#RIGHT SIDE
# set-option -g status-right '#(whoami) - #(date "+%H:%M:%S - %a - %b %d %Y")'

#Set Refresh every Second
set-option -g status-interval 1
# Disable automatic renaming
set-option -g automatic-rename on

#Prefix key + r reload config
bind R source-file ~/.tmux.conf \; display "TMUX Configuration Reloaded!"

# split current window horizontally
bind - split-window -v
# split current window vertically
bind _ split-window -h

# Shift Alt vim keys to switch windows
bind -n M-H previous-window
bind -n M-L next-window

#Plugins Install <Prefix-I> to Install
set -g @plugin 'tmux-plugins/tpm' #Plugin Manager
set -g @plugin 'tmux-plugins/tmux-sensible' #sensible commands
set -g @plugin 'jimeh/tmuxifier' #tmux persistent layouts
set -g @plugin 'tmux-plugins/tmux-yank' #tmux copy pastaaa
set -g @plugin 'catppuccin/tmux'

#<Perfix-t> or t anywhere on shell, shows all directory and creates new session
set -g @plugin 'joshmedeski/t-smart-tmux-session-manager'

# Resource TMUX Plugins
run '~/.tmux/plugins/tpm/tpm'

set -g @catppuccin_flavour "mocha"
set -g @cappuccin_window_tabs_enabled "on"
set -g @catppuccin_user "on"
set -g @catppuccin_date_time "%Y-%m-%d %H:%M:%S"

bind-key x kill-pane
set -g detach-on-destroy off #dont exit from tmux when closing session

# set vi-mode
set-window-option -g mode-keys vi
# keybindings
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

bind '"' split-window -v -c "#{pane_current_path}"
bind % split-window -h -c "#{pane_current_path}"
