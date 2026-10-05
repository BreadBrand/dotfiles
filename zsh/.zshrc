# ---- Basics / env -----------------------------------------------------------
export EDITOR=nvim
alias zshrc="$EDITOR $HOME/.zshrc"
alias reload="source $HOME/.zshrc"
alias vim="nvim"

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

# mise: node, go, zig, tree-sitter, claude, herdr (see ~/.config/mise/config.toml)
if command -v mise >/dev/null 2>&1; then
  eval "$(mise activate zsh)"
fi

command -v go >/dev/null 2>&1 && export PATH="$PATH:$(go env GOPATH)/bin"

# Secrets and machine-only settings. Lives outside the repo, so never committed.
if [ -f "$HOME/.zshrc.local" ]; then
  source "$HOME/.zshrc.local"
fi
