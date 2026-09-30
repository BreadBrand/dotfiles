# Shared by bootstrap.sh and update.sh. Source it, then call stow_all.

STOW_PACKAGES=(zsh nvim starship ghostty git mise)

# Stow one package into ~. Real files blocking a link get moved to <file>.bak-<timestamp>
# first. Omarchy migrations edit configs with `sed -i`, which replaces our symlinks with
# regular files, so this happens on existing machines too, not just fresh installs.
stow_package() {
  local pkg="$1"
  local conflicts target backup

  # The dry run exits non-zero when it finds conflicts; don't let pipefail/set -e abort here.
  conflicts="$(stow -n -R -t ~ "$pkg" 2>&1 |
    sed -nE \
      -e 's/.*over existing target (.+) since neither a link nor a directory.*/\1/p' \
      -e 's/.*existing target is neither a link nor a directory: (.+)$/\1/p' || true)"

  while IFS= read -r target; do
    [ -n "$target" ] || continue
    backup="$HOME/$target.bak-$(date +%Y%m%d%H%M%S)"
    echo "📁 Backing up ~/$target -> ${backup/#$HOME/\~}"
    mv "$HOME/$target" "$backup"
  done <<<"$conflicts"

  stow -R -t ~ "$pkg"
}

stow_all() {
  local pkg
  for pkg in "${STOW_PACKAGES[@]}"; do
    stow_package "$pkg"
  done
}
