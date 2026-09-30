# dotfiles

My setup for new machines (Arch/Omarchy via pacman, macOS via brew). Each top-level
folder is a [GNU Stow](https://www.gnu.org/software/stow/) package symlinked into `~`:

| Package    | What it configures                              |
| ---------- | ----------------------------------------------- |
| `zsh`      | `.zshrc`, plugins (as git submodules)           |
| `nvim`     | Neovim 0.12+ config using `vim.pack`            |
| `starship` | prompt                                          |
| `ghostty`  | terminal                                        |
| `git`      | `.gitconfig`                                    |
| `mise`     | node, go, zig, tree-sitter, claude, herdr       |

## New machine

### macOS

1. Install git and a C compiler: `xcode-select --install`
2. Clone over HTTPS (a new machine has no SSH key on GitHub yet):
   ```bash
   git clone --recurse-submodules https://github.com/BreadBrand/dotfiles.git ~/dotfiles
   ```
3. Run bootstrap. It installs Homebrew if needed; enter your password when asked.
   ```bash
   cd ~/dotfiles && ./bootstrap.sh
   ```
4. Restart the terminal (or open Ghostty).
5. Open `nvim` once. It installs plugins, parsers, and language servers.
6. Log in to Claude Code: `claude`

### Arch / Omarchy

1. Install git if it's missing: `sudo pacman -S git`
2. Clone over HTTPS:
   ```bash
   git clone --recurse-submodules https://github.com/BreadBrand/dotfiles.git ~/dotfiles
   ```
3. Run bootstrap. Confirm the one pacman prompt, and enter your password for `chsh`.
   ```bash
   cd ~/dotfiles && ./bootstrap.sh
   ```
4. Log out and back in, so zsh becomes your login shell.
5. Open `nvim` once. It installs plugins, parsers, and language servers.
6. Log in to Claude Code: `claude`

### After either

Once you've added an SSH key to GitHub, switch the clone to SSH so you can push:

```bash
git remote set-url origin git@github.com:BreadBrand/dotfiles.git
```

### What bootstrap does

- installs packages (`lib/install-macos.sh` or `lib/install-arch.sh`)
- sets zsh as the login shell
- fetches the zsh plugin submodules
- stows every package
- runs `mise install`

Stowing goes through `lib/stow.sh`. It keeps the package list and moves any real file
blocking a link to `<file>.bak-<timestamp>` first. Omarchy migrations edit some configs
with `sed -i`, which replaces the symlink with a plain file, so expect the occasional
backup on update too.

OS-specific shell setup lives in `zsh/.zsh/macos.zsh` and `zsh/.zsh/linux.zsh`, and
`.zshrc` loads whichever one matches.

## Secrets

This repo is public. Put API keys, tokens, and settings for a single machine in
`~/.zshrc.local`. `.zshrc` loads it last if it exists, and it lives outside the repo so it
never gets committed. `.gitignore` also blocks `*.local` and `.env` files, in case one
ends up in the repo by mistake.

## Updating

```bash
./update.sh               # pull, restow, upgrade system + mise tools, update nvim plugins/parsers/Mason
./update.sh --skip-system # same, without the pacman/brew upgrade
```

Config edits show up as soon as you pull, since everything is symlinked. `update.sh`
also takes care of the parts a pull doesn't cover: new packages to link, and updates for
plugins and system packages. If `nvim/.config/nvim/nvim-pack-lock.json` changes, commit
it so other machines get the same plugin versions.
