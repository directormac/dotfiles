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

### Before linking the dotfliles please make sure all the dependencies are installed check Install.md

## Installing <a href="https://github.com/SuperCuber/dotter">Dotter</a>

```sh
# On windows
# Install scoop, read #scoop section on Install.md
scoop install dotter

# On other platforms
# Make sure rust is installed
cargo install dotter
```

### Before running dotter create a local.toml on .dotter directory

The existing example.toml will be your reference

```toml
# For windows system paste the following lines on local.toml
includes = [".dotter/windows.toml"]
packages = ["shell","helix", "vim", ]

# For linux use the following on local.toml or omit as global config applies for unix based
packages = ["shell","helix", "vim", ]
```
