#!/usr/bin/env bash
set -euo pipefail

echo "🔧 Starting dotfiles bootstrap..."

# --- Helpers ---------------------------------------------------------------

install_if_missing() {
  local pkg="$1"

  if command -v brew >/dev/null 2>&1; then
    if ! brew list "$pkg" >/dev/null 2>&1; then
      echo "📦 Installing $pkg via brew..."
      brew install "$pkg"
    fi
  elif command -v pacman >/dev/null 2>&1; then
    if ! pacman -Qi "$pkg" >/dev/null 2>&1; then
      echo "📦 Installing $pkg via pacman..."
      sudo pacman -S --needed "$pkg"
    fi
  fi
}

install_font_if_missing() {
  local pacman_pkg="$1"
  local brew_cask="$2"
  local family="$3"

  if command -v brew >/dev/null 2>&1; then
    if ! brew list --cask "$brew_cask" >/dev/null 2>&1; then
      echo "🔤 Installing $family via brew..."
      brew install --cask "$brew_cask"
    fi
  elif command -v pacman >/dev/null 2>&1; then
    if ! pacman -Qi "$pacman_pkg" >/dev/null 2>&1; then
      echo "🔤 Installing $family via pacman..."
      sudo pacman -S --needed "$pacman_pkg"
    fi
  fi
}

# --- Install core packages -------------------------------------------------

install_if_missing zsh
install_if_missing git
install_if_missing stow
install_if_missing neovim
install_if_missing starship
install_if_missing fzf
install_if_missing ripgrep

# Ghostty is usually not in pacman official repos.
# If you're using the Ghostty binary release, keep this in:
install_if_missing ghostty || true

install_font_if_missing ttf-cascadia-code-nerd font-caskaydia-cove-nerd-font "CaskaydiaCove Nerd Font"

# --- Change login shell to Zsh if needed ----------------------------------

ZSH_PATH="$(command -v zsh || true)"

if [ -z "$ZSH_PATH" ]; then
  echo "❌ Zsh installation failed or not found."
  exit 1
fi

if [ "$SHELL" != "$ZSH_PATH" ]; then
  echo "🔁 Changing default shell to Zsh..."
  chsh -s "$ZSH_PATH"
  echo "➡️ Logout/login or restart terminal to apply Zsh."
else
  echo "✔️ Zsh already set as default shell."
fi

# --- Apply dotfiles via stow ----------------------------------------------

cd ~/dotfiles

echo "🔗 Stowing dotfiles..."
stow -D zsh 2>/dev/null || true
stow -D nvim 2>/dev/null || true
stow -D starship 2>/dev/null || true
stow -D ghostty 2>/dev/null || true

stow -t ~ zsh
stow -t ~ nvim
stow -t ~ starship
stow -t ~ ghostty

echo "✅ Dotfiles installed!"
echo "⚠️ If this is your first time running bootstrap, restart your terminal."
echo "run chmod +x bootstrap.sh"
echo "and then run ./bootstrap.sh"
