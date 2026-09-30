# Sourced by bootstrap.sh on macOS.

if ! xcode-select -p >/dev/null 2>&1; then
  echo "❌ Xcode Command Line Tools are missing (needed for git and a C compiler)."
  echo "   Run: xcode-select --install   then rerun ./bootstrap.sh"
  exit 1
fi

# --- Homebrew --------------------------------------------------------------

if ! command -v brew >/dev/null 2>&1 && [ ! -x /opt/homebrew/bin/brew ] && [ ! -x /usr/local/bin/brew ]; then
  echo "🍺 Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Apple Silicon installs to /opt/homebrew, which isn't on PATH until shellenv runs
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [ -x "$brew_bin" ]; then
    eval "$("$brew_bin" shellenv)"
    break
  fi
done

# --- Packages --------------------------------------------------------------
# zsh isn't installed: macOS ships it at /bin/zsh, and a brew zsh isn't an allowed login shell.

echo "📦 Installing packages via brew..."
brew install git stow neovim starship fzf ripgrep eza zoxide bat mise

for cask in ghostty font-caskaydia-cove-nerd-font; do
  if ! brew list --cask "$cask" >/dev/null 2>&1; then
    brew install --cask "$cask" || echo "⚠️  Couldn't install $cask (already installed outside brew?), skipping."
  fi
done

# deja is optional; .zshrc falls back to zsh-autosuggestions when it's missing.
if ! command -v deja >/dev/null 2>&1; then
  echo "⚡ Installing deja (zsh predictive suggestions)..."
  brew install Giammarco-Ferranti/deja/deja || echo "⚠️  deja install failed, zsh-autosuggestions will be used instead."
fi
