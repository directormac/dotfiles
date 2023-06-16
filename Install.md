# Installing Development Dependencies for windows

<hr>

## [Home](https://directormac/dotfiles "Home Repo")

### Dependencies

#### For Windows - Windows 11 or Windows 10

### [Scoop](http://scoop.sh "Scoop Homepage")

Scoop requires .NET Framework 4.5+ to work. Go [here](https://microsoft.com/net/download "Download link").

```powershell
#Optional: Needed to run a remote script the first

Set-ExecutionPolicy RemoteSigned -Scope CurrentUser

# Install Scoop

irm get.scoop.sh | iex
```

```powershell
# Optional: Needed to run a remote script the first
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
# Install Scoop
irm get.scoop.sh | iex
```

#### For Admin

Installation under the administrator console has been disabled by default for security considerations. If you know what you are doing and want to install Scoop as administrator. Please download the installer and manually execute it with the `-RunAsAdmin` parameter in an elevated console. Here is the example:

```powershell
irm get.scoop.sh -outfile 'install.ps1'
.\install.ps1 -RunAsAdmin [-OtherParameters ...]
# I don't care about other parameters and want a one-line command
iex "& {$(irm get.scoop.sh)} -RunAsAdmin"
```

<hr>
#### Terminal Emulators

<h3>
<a href="https://github.com/wez/wezterm">Wezterm</a> , 
<a href="https://github.com/alacritty/alacritty">Alacritty</a>
</h3>

```sh
scoop install wezterm alacritty
```

#### Shells and Git

<p>
<h4><a href="https://gitforwindows.org/">Git for windows</a> , 
<a href="https://github.com/PowerShell/PowerShell">Powershell(Optional)</a> , 
<a href="https://github.com/nushell/nushell">Nushell</a></h4>
<p>

```sh
# Installs git, git bash! pwsh(newer powershell fuck microsoft) nushell
scoop install git pwsh nu

```

<hr>
#### Base Windows Dependencies

```sh
scoop install vcredist-aio cmake make 7zip unzip wget pkg-config aria2 dotter
```

#### Shell Integrations

<h4>
  <a href="https://github.com/starship/starship">starship</a> ,
  <a href="https://github.com/lsd-rs/lsd">nsd</a> ,
  <a href="https://github.com/denisidoro/navi">navi</a> ,
  <a href="https://github.com/sharkdp/fd">fd</a> ,
  <a href="https://github.com/BurntSushi/ripgrep">ripgrep</a> ,
  <a href="https://github.com/jesseduffield/lazygit">lazygit</a> ,
  <a href="https://github.com/junegunn/fzf">fzf</a> ,
  <a href="https://github.com/veeso/termscp">termscp</a> ,
</h4>

```sh
scoop install starship lsd navi fd ripgrep lazygit fzf termscp
```

#### Shell Tools Extra

Search at <a href="https://scoop.sh">scoop</a> for their repositories

```sh
scoop install bat bottom grex tokei tealdeer dust
```

#### Editors

<h4><a href="https://github.com/neovim/neovim">Neovim</a></h4>
<h4><a href="https://github.com/helix-editor/helix">Helix</a></h4>

```sh
scoop install neovim helix
```

<hr>
#### RustUp for rust development

This package defaults to using the MSVC toolchain in new installs; use \"rustup set default-host\" to configure it,
(now equivalent to the rustup package),
According to <a href="https://doc.rust-lang.org/book/ch01-01-installation.html#installing-rustup-on-windows">The Rust Book - Chapter 1 #Installation</a>
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
scoop install rustup-msvc
```

#### For Linux - Arch based

```

```

```

```
