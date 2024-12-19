#!/bin/bash

DOTFILES_DIR="$HOME/.dotfiles" # Absolute path to your dotfiles directory
CONFIG_DIRS=("alacritty" "nvim" "helix" "wezterm" "yazi")
TARGET_DIR="/root/.config"

for dir in "${CONFIG_DIRS[@]}"; do
  echo "Linking ${dir} to ${TARGET_DIR}..."
  sudo ln -sf "${DOTFILES_DIR}/.config/${dir}" "${TARGET_DIR}/${dir}"
done

# Link .vimrc and .vim_runtime
echo "Linking .vimrc and .vim_runtime to root directory..."
sudo ln -sf "${DOTFILES_DIR}/.vimrc" "/root/.vimrc"
sudo ln -sf "${DOTFILES_DIR}/.zshrc" "/root/.zshrc"
sudo ln -sf "${DOTFILES_DIR}/.config/starship.toml" "/root/.config/starship.toml"

if [ -d "${DOTFILES_DIR}/.vim_runtime" ]; then
  sudo ln -sf "${DOTFILES_DIR}/.vim_runtime" "/root/.vim_runtime"
else
  echo "Warning: .vim_runtime directory not found. Skipping."
fi

echo "Done!"
