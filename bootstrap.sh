#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$HOME/dotfiles"

# .zshrc sources plugins from ~/dotfiles, so the repo has to live there.
if [ "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)" != "$DOTFILES_DIR" ]; then
  echo "❌ Clone this repo to $DOTFILES_DIR and run bootstrap from there."
  exit 1
fi
cd "$DOTFILES_DIR"

echo "🔧 Starting dotfiles bootstrap..."

# --- Install packages ------------------------------------------------------

case "$(uname -s)" in
  Darwin)
    . ./lib/install-macos.sh
    ;;
  Linux)
    if ! command -v pacman >/dev/null 2>&1; then
      echo "❌ Only Arch-based Linux (pacman) is supported."
      exit 1
    fi
    . ./lib/install-arch.sh
    ;;
  *)
    echo "❌ Unsupported OS: $(uname -s)"
    exit 1
    ;;
esac

# --- Change login shell to Zsh if needed ----------------------------------

ZSH_PATH="$(command -v zsh || true)"

if [ -z "$ZSH_PATH" ]; then
  echo "❌ Zsh installation failed or not found."
  exit 1
fi

if [ "$(basename "${SHELL:-}")" != "zsh" ]; then
  echo "🔁 Changing default shell to Zsh..."
  chsh -s "$ZSH_PATH"
  echo "➡️ Logout/login or restart terminal to apply Zsh."
else
  echo "✔️ Zsh already set as default shell."
fi

# --- Apply dotfiles via stow ----------------------------------------------

echo "🧩 Fetching git submodules (zsh-autosuggestions, zsh-syntax-highlighting)..."
git submodule update --init --recursive

echo "🔗 Stowing dotfiles..."
. ./lib/stow.sh
stow_all

echo "🧰 Installing mise tools (node, go, zig, tree-sitter, claude, herdr)..."
mise install

echo "✅ Dotfiles installed!"
echo "⚠️ If this is your first time running bootstrap, restart your terminal."
echo "👉 Open nvim once to install plugins, parsers and language servers."
echo "👉 To pull and apply future updates, run ./update.sh"
