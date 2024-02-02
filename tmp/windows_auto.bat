@echo off
REM Run PowerShell script to set policy
echo Y | powershell -Command "Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force"
powershell -Command "& {irm get.scoop.sh -outfile 'install.ps1'}"
powershell -Command ".\install.ps1 -RunAsAdmin"

echo "Scoop is installed proceeding to the next step"


REM Installing Windows Base Dependencies
powershell -Command "scoop install git gh cygwin mingw vcredist-aio cmake make 7zip unzip wget pkg-config aria2 dotter"

REM Disabling aria2 warnings
powershell -Command "scoop config aria2-warning-enabled false"

REM Installing Terminal Emulators
powershell -Command "scoop install wezterm alacritty windows-terminal"

REM Installing Editors
powershell -Command "scoop install neovim helix"

REM Installing Nerd Fonts
powershell -Command "scoop bucket add nerd-fonts"
powershell -Command "scoop install nerd-fonts/FiraCode-NF nerd-fonts/FiraCode-NF-Mono nerd-fonts/FiraCode-NF-Propo nerd-fonts/FiraCode"

REM Installing shells and shell integrated tools 
powershell -Command "scoop install pwsh nu starship lsd navi fd ripgrep lazygit fzf termscp"

REM Installing extra tools
powershell -Command "scoop install bat bottom grex tokei tealdeer dust tailwindcss"

REM Installing nvm
powershell -Command "scoop install nvm"
echo "Done Installing nvm"

REM Instlling lts version of node
powershell -Command "nvm install lts"
echo "Installing lts version of node"
powershell -Command "nvm use lts"
echo "Using lts as default node"
powershell -Command "scoop install pnpm yarn"

REM Installing pyenv
powershell -Command "scoop install pyenv@2.64.11"
powershell -Command "scoop hold pyenv"


echo "Installing VS Build Tools"
powershell -Command "Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_BuildTools.exe' -OutFile "$env:TEMP\vs_BuildTools.exe""
powershell -Command "& "$env:TEMP\vs_BuildTools.exe" --passive --wait --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended --remove Microsoft.VisualStudio.Component.VC.CMake.Project"

REM echo "Please wait for the VS Build Tool Installation to finish before you continue"

REM Installing Rust
powershell -Command "scoop install rustup-msvc"

REM Installing JDK
powershell -Command "scoop bucket add java"
powershell -Command "scoop install java/oraclejdk-lts"

echo "Please wait for the VS Build Tools to finish before doing anything with rust"

echo "Remember to run the following commands after the script is done"

echo "For Python"
echo "pyenv update"
echo "pyenv install 3.10.5"
echo "pyenv global 3.10.5"
echo " "
echo "For Rust"
echo "rustup component add rust-analyzer"

pause
