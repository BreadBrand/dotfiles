# macOS-only setup, sourced from .zshrc

# Homebrew isn't on PATH by default on Apple Silicon
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
  if [[ -x $brew_bin ]]; then
    eval "$($brew_bin shellenv)"
    break
  fi
done
unset brew_bin

# Work laptop SDKs
[ -f "/Users/bravo/.config/bread-machine-a72fa-6bbf07870e8b.json" ] && export GOOGLE_APPLICATION_CREDENTIALS="/Users/bravo/.config/bread-machine-a72fa-6bbf07870e8b.json"
[ -d /Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home ] && export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-17.jdk/Contents/Home
[ -f '/Users/bravo/Downloads/google-cloud-sdk/path.zsh.inc' ] && . '/Users/bravo/Downloads/google-cloud-sdk/path.zsh.inc'
[ -f '/Users/bravo/Downloads/google-cloud-sdk/completion.zsh.inc' ] && . '/Users/bravo/Downloads/google-cloud-sdk/completion.zsh.inc'
