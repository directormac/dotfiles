## Installing Development Dependencies for windows

### [Home](https://github.com/directormac/dotfiles "Home")

---

### Dependencies

#### For Windows - Windows 11 or Windows 10

### [Scoop](http://scoop.sh "Scoop Homepage")

Scoop requires .NET Framework 4.5+ to work. Go [here](https://microsoft.com/net/download "Download link").

```powershell
# Optional: Needed to run a remote script the first
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# Install Scoop
irm get.scoop.sh | iex
```

For advance installation refer to the [Installer's Readme](https://github.com/ScoopInstaller/Install#readme)

---

#### Base Windows Dependencies

```sh
scoop install git gh cygwin mingw vcredist-aio cmake make 7zip unzip wget pkg-config aria2 dotter tree-sitter
```

---

#### Terminal Emulators

### [Wezterm](https://github.com/wez/wezterm) , [Alacritty](https://github.com/alacritty/alacritty) , [Windows Terminal](https://github.com/microsoft/terminal)

```sh
scoop install wezterm alacritty windows-terminal
```

#### Shells

### [PowerShell](https://github.com/PowerShell/PowerShell) [Nushell](https://github.com/nushell/nushell)

```sh
# Installs pwsh(newer powershell fuck microsoft) nushell
scoop install pwsh nu

```

#### Shell Integrations

#### [starship](https://github.com/starship/starship), [lsd](https://github.com/lsd-rs/lsd), [navi](https://github.com/denisidoro/navi), [fd](https://github.com/sharkdp/fd), [ripgrep](https://github.com/BurntSushi/ripgrep), [lazygit](https://github.com/jesseduffield/lazygit), [fzf]("https://github.com/junegunn/fzf), [termscp](https://github.com/veeso/termscp)

```sh
scoop install starship lsd navi fd ripgrep lazygit fzf termscp
```

#### Shell Tools Extra

Search at [scoop](https://scoop.sh) for their repositories

```sh
scoop install bat bottom grex tokei tealdeer dust tailwindcss
```

#### Editors

#### [Neovim](https://github.com/neovim/neovim), [Helix](https://github.com/helix-editor/helix)

```sh
scoop install neovim helix
```

#### Nerd Fonts!

```sh
scoop bucket add nerd-fonts
scoop install nerd-fonts/FiraCode-NF nerd-fonts/FiraCode-NF-Mono nerd-fonts/Firacode-NF-Propo nerd-fonts/FiraCode

```

---

## Node Runtime

Using nvm(node version manager) refer to this [link](https://github.com/coreybutler/nvm-windows)

```sh
scoop install nvm
# Run "nvim list available" after installation
```

Install a version e.g for latest use "latest" and for lts use "lts"

```sh
nvm install lts
```

Dependency Managers Install per nvim instance e.g

```sh
nvm use lts
# Using scoop to manage yarn and pnpm versions
scoop install pnpm yarn
```

---

### Rust

This package defaults to using the MSVC toolchain in new installs; use \"rustup set default-host\" to configure it,
(now equivalent to the rustup package),
According to [The Rust Book - Chapter 1](https://doc.rust-lang.org/book/ch01-01-installation.html#installing-rustup-on-windows)
Microsoft C++ Build Tools is needed and can be downloaded <a href="https://visualstudio.microsoft.com/visual-cpp-build-tools/">here</a>!

When installing build tools, these two components should be selected:,

- MSVC - VS C++ x64/x86 build tools,
- Windows SDK

Or you can run this script below in powershell cause fuck microsoft!

```powershell
Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_BuildTools.exe' -OutFile "$env:TEMP\vs_BuildTools.exe"
& "$env:TEMP\vs_BuildTools.exe" --passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --remove Microsoft.VisualStudio.Component.VC.CMake.Project
```

```sh
# Install rustup through scoop
scoop install rustup-msvc
```

---

#### Other Runtimes

**[Python](https://pyenv-win.github.io/pyenv-win/)**

```sh
scoop install pyenv@2.64.11 #other versions not working well
scoop hold pyenv
```

---

**[Java(JDK)](https://jdk.java.net/)** With android-clt

Flavours available openjdk, oraclejdk, oraclejdk-lts

```sh
scoop bucket add extras
scoon install java/openjdk17 # Dependency
scoop install main/android-clt # Replaces Android SDK
scoop install extras/android-studio # Instructions Below
```

This is the only time you need to open it for initial setup and adding emulator
TODO: Discover how android-clt works didnt see any shims from scoop either

1. Open Android Studio
2. It will ask for Android SDK after you install openjdk17 and android-clt this will be auto detected
3. Let it download what it needs next next next next next next and finish
4. Create an emulator run it for the first time
5. Forget you installed android studio 🤖

## Specific Configuration Snippets

Append this to the settings.json on object schemes at ~/scoop/apps/windows-terminal/current/settings/settings.json

```json
    {
      "name": "Catppuccin Mocha",
      "cursorColor": "#F5E0DC",
      "selectionBackground": "#585B70",
      "background": "#1E1E2E",
      "foreground": "#CDD6F4",
      "black": "#45475A",
      "red": "#F38BA8",
      "green": "#A6E3A1",
      "yellow": "#F9E2AF",
      "blue": "#89B4FA",
      "purple": "#F5C2E7",
      "cyan": "#94E2D5",
      "white": "#BAC2DE",
      "brightBlack": "#585B70",
      "brightRed": "#F38BA8",
      "brightGreen": "#A6E3A1",
      "brightYellow": "#F9E2AF",
      "brightBlue": "#89B4FA",
      "brightPurple": "#F5C2E7",
      "brightCyan": "#94E2D5",
      "brightWhite": "#A6ADC8"
    },
```
