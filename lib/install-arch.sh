# Sourced by bootstrap.sh on Arch (and Omarchy).

# One -Syu up front: syncs the package list so installs don't 404 on a fresh system, and
# Arch doesn't support installing new packages against a stale partial upgrade anyway.
# base-devel provides the C compiler nvim-treesitter needs; unzip is needed by Mason.
echo "📦 Installing packages via pacman..."
sudo pacman -Syu --needed \
  zsh git stow neovim starship fzf ripgrep eza zoxide bat mise ghostty \
  ttf-cascadia-code-nerd base-devel unzip curl tar

# deja is optional; .zshrc falls back to zsh-autosuggestions when it's missing.
if ! command -v deja >/dev/null 2>&1; then
  echo "⚡ Installing deja (zsh predictive suggestions)..."
  curl -fsSL https://raw.githubusercontent.com/Giammarco-Ferranti/deja/main/install.sh | sh ||
    echo "⚠️  deja install failed, zsh-autosuggestions will be used instead."
fi
