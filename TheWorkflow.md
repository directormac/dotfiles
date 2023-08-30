# The DX

A workflow sets of scripts and bindings that should be adaptable to any workflow.

## Install Arch Notes

## Arch Dependencies

Base

```sh
pacman -S --needed base-devel git neovim helix zsh rustup unzip
# Fonts
pacman -S ttf-fira-code ttf-fira-mono ttf-fira-sans ttf-firacode-nerd otf-firamono-nerd ttf-jeybrains-mono ttf-jetbrains-mono-nerd
```

### Git

```sh
git config --global user.name "Artifex"
git config --global user.email "artfiex@mkra.dev"
git config --global core.editor "nvim"
git config --global init.defaultBranch "main"
```

### Rustup

paru dependency, and for rust projects ‍

```sh
# Install
sudo pacman -S rustup

# Install stable toolchain
rustup toolchain install stable
# Install completions for zsh
rustup completions zsh cargo
```

### Paru AUR Helper

[Repo](https://github.com/Morganamilo/paru)

Install

```sh
# sudo pacman -S --needed base-devel
mkdir temp && cd temp # Create a temp directory and cd into it
git clone https://aur.archlinux.org/paru.git # Clone paru
cd paru # Change directory into paru
makepkg -si # Installation requires rustup
cd # Change back to home directory
paru
```

Test paru by installing additional Fonts & a dotfiles manager

```sh
paru -S ttf-devicons ttf-octicons
paru -S dotter-rs-bin
```

### zsh and Utilities

Set zsh as default shell

```sh
# Run zsh
zsh
# Set zsh as default shell for you
sudo chsh -s $(which zsh) $USER
# Set zsh as default shell for root do not do this
sudo chsh -s $(which zsh)
```

#### Shell Utilities

- [starship](https://starship.rs/)
- [lsd](https://github.com/lsd-rs/lsd)
- [zoxide](https://github.com/ajeetdsouza/zoxide)
- [bat](https://github.com/sharkdp/bat)
- [navi](https://github.com/denisidoro/navi)
- [fd](https://github.com/shakdp/fd)
- [bottom](https://github.com/ClementTsang/bottom)
- [ripgrep](https://github.com/BurntSushi/ripgrep)
- [lazygit](https://github.com/jesseduffield/lazygit)
- [fzf ](https://github.com/junegunn/fzf)
- [termscp](https://github.com/veeso/termscp)

```sh
sudo pacman -S starship lsd zoxide bat navi fd bottom ripgrep lazygit fzf
paru -Sy termscp
```

<!-- TODO: zsh plugin manager -->

[Zap](https://github.com/zap-zsh/zap)

```sh
zsh <(curl -s https://raw.githubusercontent.com/zap-zsh/zap/master/install.zsh) --branch release-v1
```

<!-- TODO: Usage -->

Installing zsh plugins

Add the following to your `.zshrc`

```sh
# Example install of plugins
plug "zsh-users/zsh-autosuggestions"
# Example install of a plugin pinned to specifc commit or branch, just pass the git reference
plug "zsh-users/zsh-syntax-highlighting" "122dc46"
```

Commands

```sh
zap update self # Update the Zap installation
zap update plugins # Update all your plugins but not Zap
zap update all # Update both the Zap installation and its plugins
zap list # List all plugins you are using
zap clean # Remove unused plugins
```

Uinstall

```sh
rm -rf "${XDG_DATA_HOME:-$HOME/.local/share}/zap"
```

<!-- TODO: Add zshrc functions and aliases -->

### Tmux

[Wiki](https://github.com/tmux/tmux/wiki)

```sh
# Install tmux
sudo pacman -S tmux
```

<!-- TODO: Tmux configuration -->

Plugin Manager

Repo links

- [tmux-sensible](https://github.com/tmux-plugins/tmux-sensible)
- [tmux-resurrect](https://github.com/tmux-plugins/tmux-resurrect)
- [tmux-continuum](https://github.com/tmux-plugins/tmux-continuum)
- [tmux-session-wizard](https://github.com/27medkamal/tmux-session-wizard)
- [tmux-open]()
-
-

```sh
# Install tmux plugin manager
paru -S tmux-plugin-manager
echo "# Plugins

# Plugins Install <Prefix-I> to Install
set -g @plugin 'tmux-plugins/tmux-sensible' #sensible commands
set -g @plugin 'tmux-plugins/tmux-resurrect' # resurrect sessions
set -g @plugin 'tmux-plugins/tmux-continuum' # works with resurrreect
set -g @plugin 'tmux-plugins/tmux-pain-control' # manage panes and windowsss

set -g @plugin 'jimeh/tmuxifier' #tmux persistent layouts

# <Perfix-t> or t anywhere on shell, shows all directory and creates new session
set -g @plugin '27medkamal/tmux-session-wizard'

# Plugin Configurations




# Should be at the bottom of the file
run '/usr/share/tmux-plugin-manager/tpm'" >> ~/.tmux.conf

# Activate t command to run it on the shell
cp ~/.dotfiles/scripts/session-wizard.sh > /usr/local/bin/t && chmod u+x /usr/local/bin/t
```

Configuration Overrides & Key Bindings

<!-- TODO: Add keybindings -->

<!-- TODO: Usage -->

## Dev Dependencies

- [Node Version Manager](https://bun.sh/)

```sh
# from AUR
paru -S --noconfirm nvm

# Option 1
echo "source /usr/share/nvm/init-nvm.sh" >> ~/.zshrc

# Option 2
echo
"# nvm
[ -z \"\$NVM_DIR\"] && export NVM_DIR=\"\$HOME/.nvm\"
source /usr/share/nvm/nvm.sh
source /usr/share/nvm/bash_completion
source /usr/share/nvm/install-nvm-exec
# nvm
" >> ~/.zshrc

# Install LTS
nvm install --lts
nvm use --lts
```

<!-- TODO: Usage -->

- [pnpm](https://pnpm.io/installation)

Installation

```sh
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Adding pnpm to our shell
echo "# pnpm
export PNPM_HOME=\"\$HOME/.local/share/pnpm\"
case \":\$PATH:\" in
  *\":\$PNPM_HOME:\" ;;
  *) export PATH=\"\$PNPM_HOME:\$PATH\" ;;
esac
# pnpm end" >> ~/.zshrc

```

Additional dependencies

```sh
# Add tabtab completions
pnpm install-completion zsh
# Completion with --filter
paru -S pnpm-shell-completion
echo "source /usr/share/zsh/plugins/pnpm-shell-completion/pnpm-shell-completion.zsh" >> ~/.zshrc
```

<!-- TODO: Usage -->

- [bun](https://bun.sh/)

Install from AUR

```sh
paru -S bunjs-bin
```

- [deno](https://deno.land)

```sh
sudo pacman -S deno
```
