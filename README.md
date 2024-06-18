# A dotfiles configuration

Dependencies

- [feh](https://feh.finalrewind.org/) for wallpapers
- [alacritty](https://github.com/alacritty/alacritty)
- [wezterm](https://github.com/wez/wezterm)
- [tmux](https://github.com/tmux/tmux)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [nvim](https://github.com/neovim/neovim)
- [i3](https://github.com/i3/i3)
- [polybar](https://github.com/polybar/polybar)
- [rofi](https://github.com/davatorium/rofi)
- [rofi-emoji](https://github.com/Mange/rofi-emoji)

## Installations

The following i3 configuration files are meant to run for

[archcraft](https://github.com/archcraft-os/archcraft) an arch linux distro

### GNU Stow

`pacman -S stow`

```sh
#clone repo using gh cli
gh repo clone directormac/dotfiles ~/.dotfiles

#clone repo using git
git clone https://github.com/directormac/dotfiles.git ~/.dotfiles
```

Usage

```sh
# Link
stow .

# Unlink
stow -D .
```
