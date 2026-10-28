# ---- Basics / env -----------------------------------------------------------
export EDITOR=nvim
alias zshrc="$EDITOR $HOME/.zshrc"
alias reload="source $HOME/.zshrc"
alias vim="nvim"
alias v8="node --allow-natives-syntax "

# OS-specific setup (Homebrew PATH, Linux-only env). Loaded early so later tools are on PATH.
case "$OSTYPE" in
  darwin*) source ~/dotfiles/zsh/.zsh/macos.zsh ;;
  linux*) source ~/dotfiles/zsh/.zsh/linux.zsh ;;
esac

# History
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

# Completion
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)   # Include dotfiles in completion

eval "$(starship init zsh)"

# No bell
unsetopt BEEP

# vi mode
bindkey -v
# ---- Vi-mode cursor shapes (Ghostty/iTerm/Kitty support DECSCUSR) ----
# 2 = steady block, 6 = steady bar
_cursor_block() { printf '\e[2 q'; }   # NORMAL mode
_cursor_bar()   { printf '\e[6 q'; }   # INSERT mode

# Switch shape when the keymap changes
function zle-keymap-select {
  case $KEYMAP in
    vicmd) _cursor_block ;;            # ESC -> NORMAL
    main|viins) _cursor_bar ;;         # any insert state
  esac
  zle -R                                # refresh prompt
}
zle -N zle-keymap-select

# Set initial cursor when line editor starts
function zle-line-init {
  zle -K viins
  _cursor_bar
}
zle -N zle-line-init

# Optional: ensure a sane cursor before each external command runs
preexec() { _cursor_block; }

export KEYTIMEOUT=1
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -v '^?' backward-delete-char

# ---- vi-mode yank to the system clipboard -----------------------------------
# zsh ships the `visual` keymap with no `y` binding, so V then y does nothing.
# And vi-yank only fills zsh's internal cutbuffer, which `p` can paste but the
# system clipboard never sees. Bind y and mirror the yank outward, so it behaves
# like nvim with clipboard=unnamedplus.
_clip_copy() {
  if command -v pbcopy >/dev/null 2>&1; then pbcopy
  elif command -v wl-copy >/dev/null 2>&1; then wl-copy
  elif command -v xclip >/dev/null 2>&1; then xclip -selection clipboard
  else cat >/dev/null
  fi
}

_vi_yank_clip() {
  zle vi-yank
  printf '%s' "$CUTBUFFER" | _clip_copy
}
zle -N _vi_yank_clip

_vi_yank_line_clip() {
  zle vi-yank-whole-line
  printf '%s' "$CUTBUFFER" | _clip_copy
}
zle -N _vi_yank_line_clip

bindkey -M visual 'y' _vi_yank_clip      # V, motion, y  -> selection
bindkey -M vicmd  'Y' _vi_yank_line_clip # Y             -> whole line

# Paste from the system clipboard instead of zsh's internal cutbuffer, so p
# pairs with the y above. Load the clipboard into CUTBUFFER, then let the stock
# widget do the actual insertion and cursor placement.
_clip_paste() {
  if command -v pbpaste >/dev/null 2>&1; then pbpaste
  elif command -v wl-paste >/dev/null 2>&1; then wl-paste --no-newline
  elif command -v xclip >/dev/null 2>&1; then xclip -selection clipboard -o
  fi
}

_vi_put_after_clip()  { CUTBUFFER="$(_clip_paste)"; zle vi-put-after; }
_vi_put_before_clip() { CUTBUFFER="$(_clip_paste)"; zle vi-put-before; }
_put_replace_clip()   { CUTBUFFER="$(_clip_paste)"; zle put-replace-selection; }
zle -N _vi_put_after_clip
zle -N _vi_put_before_clip
zle -N _put_replace_clip

bindkey -M vicmd  'p' _vi_put_after_clip   # p -> paste clipboard after cursor
bindkey -M vicmd  'P' _vi_put_before_clip  # P -> paste clipboard before cursor
bindkey -M visual 'p' _put_replace_clip    # p -> replace selection with clipboard

# fzf keybindings/completion (safe)
if command -v fzf >/dev/null 2>&1; then
  source <(fzf --zsh)
fi

# Edit line in $EDITOR with Ctrl-E
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line

# Git aliases
alias gs='git status'
alias ga='git add'
alias gaa='git add .'
alias gcm='git commit -m'
alias gd='git diff'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gb='git branch'
alias gbD='git branch -D'
alias gr='git remote'
alias grb='git rebase -i'
alias gap='git add -p'
alias gl='git log'
alias gpl='git pull'
alias gps='git push'
alias gpu='git push --set-upstream origin'
alias grs='git restore'
alias gst='git stash'
alias gstp='git stash pop'

# ---------- Filesystem ----------
alias ls='eza -lh --group-directories-first --icons=auto'
alias lsa='ls -a'
alias lt='eza --tree --level=2 --long --icons --git'
alias lta='lt -a'
alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

# Use zoxide instead of redefining cd
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
else
  # fallback cd behavior
  alias ..='cd ..'
  alias ...='cd ../..'
  alias ....='cd ../../..'
fi

# ---------- Zoxide + FZF Integration ----------
# Use Alt-c to jump to a directory from zoxide using fzf
fzf_z() {
  local dir
  dir=$(zoxide query -l | fzf --height 40% --reverse --prompt='Jump to dir> ') || return
  if [[ -n "$dir" ]]; then
    cd "$dir" || return
    zle reset-prompt
  fi
}
zle -N fzf_z
bindkey '^[c' fzf_z

vf() {
  local f
  f=$(fd --type f --hidden "${2:-.}" "${1:-$HOME}" | fzf) && vim "$f"
}

# ---- Plugins (order matters: suggestions, then highlighting last) -----------
if command -v deja >/dev/null 2>&1; then
  export DEJA_CYCLE_KEY='^[[Z'   # Shift+Tab for alternatives picker; keep Tab for completion/fzf
  if [[ -r "$HOME/.local/share/deja/init.zsh" ]]; then
    source "$HOME/.local/share/deja/init.zsh"
  else
    eval "$(deja init zsh)"
  fi
else
  source ~/dotfiles/zsh/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
fi
source ~/dotfiles/zsh/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Optional: colors available for scripts that need them (doesn't set PS1)
autoload -U colors && colors

# custom command menus
export PATH="$HOME/.local/bin/mine:$PATH"

# Keep custom env last
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
export PATH="$HOME/.local/bin:$PATH"

# nvm: put the default version's bin directly on PATH. Sourcing nvm.sh costs
# ~0.6s and `nvm use` another ~0.7s, which is too much to pay in every shell --
# and sourcing alone selects no version, so node would fall through to whatever
# else is on PATH (Homebrew ships a much newer major). Read the default alias
# and prepend; the nvm function itself loads lazily on first call below.
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/alias/default" ]; then
  _nvm_ver="$(<"$NVM_DIR/alias/default")"
  _nvm_bin="$NVM_DIR/versions/node/v${_nvm_ver#v}/bin"
  [ -d "$_nvm_bin" ] && export PATH="$_nvm_bin:$PATH"
  unset _nvm_ver _nvm_bin
fi

# Real nvm on demand: load it, remove this shim, re-dispatch. Note the fast path
# above only understands a plain version in alias/default -- if you set it to
# something like `lts/*`, run `nvm use` once in the shell instead.
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
  nvm "$@"
}

# mise: node, go, zig, tree-sitter, claude, herdr (see ~/.config/mise/config.toml)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

command -v go >/dev/null 2>&1 && export PATH="$PATH:$(go env GOPATH)/bin"

# Dart/Flutter global binaries
[ -d "$HOME/.pub-cache/bin" ] && export PATH="$PATH:$HOME/.pub-cache/bin"

# Per-directory environments
command -v direnv >/dev/null 2>&1 && eval "$(direnv hook zsh)"

# Secrets and machine-only settings. Lives outside the repo, so never committed.
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi

# Rex prepends its own rex binary to PATH before our startup files run, so anything
# above that rebuilds or reorders PATH can drop it or shadow it with another copy.
# Re-prepend it last. Outside Rex the variable is empty and this is a no-op.
if [ -n "$REX_BIN_DIR" ]; then
    export PATH="$REX_BIN_DIR:$PATH"
fi
export NODE_EXTRA_CA_CERTS="/Library/Application Support/Netskope/STAgent/data/nscacert_combined.pem"
