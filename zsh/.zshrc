# ---- Basics / env -----------------------------------------------------------
export EDITOR=nvim
export SDL_VIDEODRIVER='wayland,x11'
alias zshrc="$EDITOR $HOME/.zshrc"
alias zsh="source $HOME/.zshrc"
alias lsa="ls -a"
alias vim="nvim"

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

#Domo specific alias'
gcod() {
  if [ -z "$1" ]; then
    echo "Error: Please provide a ticket number. Usage: gcod <TICKET_NUMBER>"
    return 1
  fi
  git checkout users/brandon.bashein/$1
}
gcbd() {
  if [ -z "$1" ]; then
    echo "Error: Please provide a ticket number. Usage: gcb <TICKET_NUMBER>"
    return 1
  fi
  git checkout -b users/brandon.bashein/$1
}
gpud() {
  if [ -z "$1" ]; then
    echo "Error: Please provide a ticket number. Usage: gpud <TICKET_NUMBER>"
    return 1
  fi
  git push --set-upstream origin users/brandon.bashein/$1
}
gbdd() {
  git branch | grep '^\s*users' | xargs -r git branch -d 
}

alias domorun='pnpm start --watchI18n --proxy="https://*.domo.com" --port=80 --skip-translations --noTypeCheck'
alias domoruntypecheck='pnpm start --watchI18n --proxy="https://*.domo.com" --port=80 --skip-translations'
alias runoldbranch='./runPnpm start --watchI18n --proxy"https://*.domo.com" --port=80 --skip-translations --noTypeCheck'

alias embedrun='pnpm start --gateway https://api.dev.domo.com'

export PNPM_HOME="/Users/brandon.bashein/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# End Domo specific alias'

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

# ---------- Fuzzy File Picker -------------------
bindkey '^T' fzf-file-widget

# open files with system default app
open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Your env vars / SDKs (keep as needed)
export GOOGLE_APPLICATION_CREDENTIALS="/Users/bravo/.config/bread-machine-a72fa-6bbf07870e8b.json"
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home

# Google Cloud SDK
[ -f '/Users/bravo/Downloads/google-cloud-sdk/path.zsh.inc' ] && . '/Users/bravo/Downloads/google-cloud-sdk/path.zsh.inc'
[ -f '/Users/bravo/Downloads/google-cloud-sdk/completion.zsh.inc' ] && . '/Users/bravo/Downloads/google-cloud-sdk/completion.zsh.inc'

# ---- Plugins (order matters: autosuggestions, then highlighting last) -------
source ~/dotfiles/zsh/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/dotfiles/zsh/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Optional: colors available for scripts that need them (doesn't set PS1)
autoload -U colors && colors

# Keep custom env last
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"


. "$HOME/.local/share/../bin/env"
export PATH="$HOME/.local/bin:$PATH"

# Added by LM Studio CLI tool (lms)
export PATH="$PATH:/home/bash/.lmstudio/bin"
export PATH="/opt/rocm/bin:$PATH"
