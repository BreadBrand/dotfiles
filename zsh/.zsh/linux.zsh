# Linux-only setup, sourced from .zshrc
export SDL_VIDEODRIVER='wayland,x11'

# open files with system default app, like macOS `open`
open() {
  xdg-open "$@" >/dev/null 2>&1 &
}

# Added by LM Studio CLI tool (lms)
[ -d "$HOME/.lmstudio/bin" ] && export PATH="$PATH:$HOME/.lmstudio/bin"
[ -d /opt/rocm/bin ] && export PATH="/opt/rocm/bin:$PATH"
