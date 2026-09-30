#!/usr/bin/env bash
set -euo pipefail

# Usage: ./update.sh [--skip-system]
#   --skip-system  don't upgrade system packages (pacman/brew)

SKIP_SYSTEM=false
for arg in "$@"; do
  case "$arg" in
    --skip-system) SKIP_SYSTEM=true ;;
    *) echo "Unknown option: $arg" >&2; exit 1 ;;
  esac
done

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$DOTFILES_DIR"

echo "🔄 Starting dotfiles update..."

# --- Pull latest dotfiles --------------------------------------------------

echo "⬇️  Pulling latest dotfiles..."
git pull --ff-only --autostash

echo "🧩 Updating git submodules..."
git submodule update --init --recursive

# --- Re-stow (picks up any new files/packages) -----------------------------

echo "🔗 Restowing dotfiles..."
. ./lib/stow.sh
stow_all

# --- System packages -------------------------------------------------------

# Reuse bootstrap's install scripts so packages added to them since the last run get
# installed here too, not just on fresh machines.
if [ "$SKIP_SYSTEM" = false ]; then
  case "$(uname -s)" in
    Darwin)
      . ./lib/install-macos.sh
      echo "📦 Upgrading brew packages..."
      brew update
      brew upgrade
      ;;
    Linux)
      # pacman -Syu in here upgrades the whole system too
      . ./lib/install-arch.sh
      ;;
  esac
else
  echo "⏭️  Skipping system package upgrades."
fi

# --- mise tools ------------------------------------------------------------

if command -v mise >/dev/null 2>&1; then
  echo "🧰 Installing and upgrading mise tools..."
  # install picks up tools newly added to the config; upgrade only touches installed ones
  mise install
  mise upgrade
  # put mise's go/node on PATH so Mason can build gopls, sqls, etc. below
  eval "$(mise activate bash --shims)"
fi

# --- Neovim ----------------------------------------------------------------

if command -v nvim >/dev/null 2>&1; then
  NVIM_LUA="$(mktemp "${TMPDIR:-/tmp}/dotfiles-update.XXXXXX")"
  trap 'rm -f "$NVIM_LUA"' EXIT

  echo "🔌 Updating nvim plugins..."
  cat >"$NVIM_LUA" <<'EOF'
vim.pack.update(nil, { force = true })

-- reset the once-a-day auto-update stamp so nvim doesn't re-check on next launch
local fd = io.open(vim.fn.stdpath("state") .. "/pack_update_stamp", "w")
if fd then
  fd:write(tostring(os.time()))
  fd:close()
end
EOF
  nvim --headless "+luafile $NVIM_LUA" +qa

  # Separate nvim run so the freshly updated plugin code is loaded.
  echo "🌳 Updating treesitter parsers and Mason packages..."
  cat >"$NVIM_LUA" <<'EOF'
require("nvim-treesitter").update():wait(300000)

local registry = require("mason-registry")
local refreshed = false
registry.refresh(function() refreshed = true end)
vim.wait(60000, function() return refreshed end, 200)

-- mason-lspconfig skips ensure_installed in headless mode, so run it ourselves.
-- mason-nvim-dap already kicked off its installs on startup. Wait for all of them below.
require("mason-lspconfig.features.ensure_installed")()
local startup_installs = vim.tbl_filter(function(pkg) return pkg:is_installing() end, registry.get_all_packages())

local pending = 0
for _, pkg in ipairs(registry.get_installed_packages()) do
  local installed = pkg:get_installed_version()
  local latest = pkg:get_latest_version()
  if installed ~= latest and not pkg:is_installing() then
    io.write(("mason: %s %s -> %s\n"):format(pkg.name, installed or "?", latest))
    pending = pending + 1
    pkg:install({}, function(success, err)
      if not success then
        io.write(("mason: failed to update %s: %s\n"):format(pkg.name, vim.inspect(err)))
      end
      pending = pending - 1
    end)
  end
end
vim.wait(600000, function()
  return pending == 0 and not vim.iter(startup_installs):any(function(pkg) return pkg:is_installing() end)
end, 500)
EOF
  nvim --headless "+luafile $NVIM_LUA" +qa
  echo
fi

# --- Summary ---------------------------------------------------------------

echo "✅ Update complete!"
if ! git diff --quiet -- nvim/.config/nvim/nvim-pack-lock.json; then
  echo "📝 nvim-pack-lock.json changed. Commit it to sync plugin versions across machines."
fi
