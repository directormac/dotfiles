# A dotfiles configuration

<hr>

This dotfiles repo has the following configuration for

## 🚀 Configuration for

- <a href="https://github.com/neovim/neovim">Neovim</a>
- <a href="https://github.com/helix-editor/helix">Helix</a>
- <a href="https://github.com/tmux/tmux/wiki">Tmux</a>
- <a href="https://github.com/ohmyzsh/ohmyzsh/wiki/Installing-ZSH">Zsh</a>
- <a href="https://github.com/starship/starship">Starship</a>
- <a href="https://github.com/jesseduffield/lazygit">Lazygit</a>
- <a href="https://github.com/alacritty/alacritty">Alacritty</a>

<hr>

Dependencies `gnu stow`

Installation:

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
