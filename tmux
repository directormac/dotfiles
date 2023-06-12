# Tmux Configuration
# Must not overide with neovim and wezterm

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
# Prefix key is default <C-b>
#Vim style pane selection <Prefix-key>
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
# <Prefix-x>
bind-key x kill-pane
#Use alt-arrow keys without prefix key to switch panes
# bind -n M-Left select-pane -L
# bind -n M-Right select-pane -D
# bind -n M-Up select-pane -U
# bind -n M-Down select-pane -R
# Split current window horizontally
# bind - split-window -v
# Split current window vertically
# bind | split-window -h
bind - split-window -v -c "#{pane_current_path}" #split to current path
bind | split-window -h -c "#{pane_current_path}" #split to current path

#Prefix key + r reload config
bind R source-file ~/.tmux.conf \; display "TMUX Configuration Reloaded!"

# Non prefixed key
# Shift Alt vim keys to switch windows
bind -n M-H previous-window
bind -n M-L next-window
# set vi-mode
# set-window-option -g mode-keys vi
# keybindings
# bind-key -T copy-mode-vi v send-keys -X begin-selection
# bind-key -T copy-mode-vi C-v send-keys -X rectangle-toggle
# bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel

#Catppuccin Theme Options
set -g @catppuccin_flavour "mocha"
set -g @cappuccin_window_tabs_enabled "on"
set -g @catppuccin_user "on"
set -g @catppuccin_left_separator "█"
set -g @catppuccin_right_separator "█"
# set -g @catppuccin_date_time "%Y-%m-%d %H:%M:%S"
# set -g @catppuccin_datetime_icon "A"
# set -g @catppuccin_user_icon "B"
# set -g @catppuccin_directory_icon "C"
 # set -g @catppuccin_window_icon "D"
# set -g @catppuccin_session_icon "E"
# set -g @catppuccin_host_icon "F"

# End of catppuccin section

#Plugins Install <Prefix-I> to Install
set -g @plugin 'tmux-plugins/tpm' #Plugin Manager
set -g @plugin 'tmux-plugins/tmux-sensible' #sensible commands
set -g @plugin 'jimeh/tmuxifier' #tmux persistent layouts
set -g @plugin 'tmux-plugins/tmux-yank' #tmux copy pastaaa
set -g @plugin 'catppuccin/tmux' #soothing pastel colored theme

#<Perfix-t> or t anywhere on shell, shows all directory and creates new session
set -g @plugin 'joshmedeski/t-smart-tmux-session-manager'

# Resource TMUX Plugins
run '~/.tmux/plugins/tpm/tpm'
# Unused
# #STATUS BAR SECTION
#Set status bar color
# set-option -g status-style bg=default #transparent statusbar
#Justify statusbar center
# set -g status-justify centre
#LEFT SIDE
# set-option -g status-left '#{session_name}'
#RIGHT SIDE
# set-option -g status-right '#(whoami) - #(date "+%H:%M:%S - %a - %b %d %Y")'
