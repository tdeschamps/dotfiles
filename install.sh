#!/usr/bin/env bash
#
# Dotfiles installer. Safe to run more than once.
#
#   bash install.sh
#
# Everything is symlinked, so editing a file in this repo edits the live config.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

BOLD=$'\033[1m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'; RED=$'\033[0;31m'; RESET=$'\033[0m'

info()  { printf '%s==>%s %s\n' "$GREEN" "$RESET" "$1"; }
warn()  { printf '%s==>%s %s\n' "$YELLOW" "$RESET" "$1"; }
error() { printf '%s==>%s %s\n' "$RED" "$RESET" "$1" >&2; }
step()  { printf '\n%s%s%s\n' "$BOLD" "$1" "$RESET"; }

# link <source-in-repo> <destination>
link() {
  local src="$DOTFILES/$1" dest="$2"

  if [ ! -e "$src" ]; then
    error "missing source file: $src"
    return 1
  fi

  mkdir -p "$(dirname "$dest")"

  # Already pointing where we want it.
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    return 0
  fi

  # Back up anything real that is in the way.
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ]; then
      rm "$dest"
    else
      mv "$dest" "$dest.backup"
      warn "moved existing $dest to $dest.backup"
    fi
  fi

  ln -s "$src" "$dest"
  info "linked $dest"
}

#
# 1. Homebrew
#
step "Homebrew"
if ! command -v brew >/dev/null 2>&1; then
  for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
    if [ -x "$prefix/bin/brew" ]; then
      eval "$("$prefix/bin/brew" shellenv)"
      break
    fi
  done
fi

if ! command -v brew >/dev/null 2>&1; then
  info "installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  for prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew; do
    if [ -x "$prefix/bin/brew" ]; then
      eval "$("$prefix/bin/brew" shellenv)"
      break
    fi
  done
fi

if command -v brew >/dev/null 2>&1; then
  info "installing packages from Brewfile"
  brew update
  brew bundle --file="$DOTFILES/Brewfile"
else
  warn "Homebrew is not available; skipping package installation"
fi

#
# 2. Symlinks
#
step "Linking configuration"

# fish: link file by file so fisher's own output stays out of this repo
mkdir -p "$XDG_CONFIG_HOME/fish/conf.d" "$XDG_CONFIG_HOME/fish/functions"
link "config/fish/config.fish" "$XDG_CONFIG_HOME/fish/config.fish"
link "config/fish/fish_plugins" "$XDG_CONFIG_HOME/fish/fish_plugins"
for file in "$DOTFILES"/config/fish/conf.d/*.fish; do
  link "config/fish/conf.d/$(basename "$file")" "$XDG_CONFIG_HOME/fish/conf.d/$(basename "$file")"
done
for file in "$DOTFILES"/config/fish/functions/*.fish; do
  link "config/fish/functions/$(basename "$file")" "$XDG_CONFIG_HOME/fish/functions/$(basename "$file")"
done

# neovim, tmux, starship
link "config/nvim" "$XDG_CONFIG_HOME/nvim"
link "config/tmux/tmux.conf" "$XDG_CONFIG_HOME/tmux/tmux.conf"
link "config/starship.toml" "$XDG_CONFIG_HOME/starship.toml"

# git
link "config/git/config" "$XDG_CONFIG_HOME/git/config"
link "config/git/gitignore" "$XDG_CONFIG_HOME/git/gitignore"
link "config/git/gitmessage" "$XDG_CONFIG_HOME/git/gitmessage"
link "config/git/gitk" "$XDG_CONFIG_HOME/git/gitk"

if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
  warn "$HOME/.gitconfig exists and takes precedence over the config linked above."
  warn "Merge anything you still need out of it, then remove it."
fi

# ssh. The directory must be 0700 and ControlPath needs its parent to exist;
# ssh creates neither.
mkdir -p "$HOME/.ssh/control"
chmod 700 "$HOME/.ssh" "$HOME/.ssh/control"
link "config/ssh/config" "$HOME/.ssh/config"

# ruby
link "gemrc" "$HOME/.gemrc"
link "irbrc" "$HOME/.irbrc"
link "rspec" "$HOME/.rspec"

#
# 3. fish plugins
#
step "fish plugins"
if command -v fish >/dev/null 2>&1; then
  fisher_fn="$XDG_CONFIG_HOME/fish/functions/fisher.fish"
  if [ ! -e "$fisher_fn" ]; then
    info "installing fisher"
    curl -fsSL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish \
      -o "$fisher_fn"
  fi
  fish -c "source $fisher_fn && fisher update"
else
  warn "fish is not installed; skipping plugin installation"
fi

#
# 4. tmux plugin manager
#
step "tmux plugins"
TPM_DIR="$XDG_CONFIG_HOME/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"
  info "installed tpm — press prefix + I inside tmux to fetch the plugins"
else
  info "tpm already installed"
fi

#
# 5. Default shell
#
step "Default shell"
FISH_PATH="$(command -v fish || true)"
if [ -n "$FISH_PATH" ]; then
  if [ "${SHELL:-}" != "$FISH_PATH" ]; then
    if ! grep -qxF "$FISH_PATH" /etc/shells 2>/dev/null; then
      info "adding $FISH_PATH to /etc/shells (sudo required)"
      echo "$FISH_PATH" | sudo tee -a /etc/shells >/dev/null \
        || warn "could not write /etc/shells; set your shell manually"
    fi
    info "setting fish as your login shell"
    chsh -s "$FISH_PATH" || warn "chsh failed; set fish as your login shell manually"
  else
    info "fish is already your login shell"
  fi
fi

#
# 6. Neovim
#
step "Neovim"
if command -v nvim >/dev/null 2>&1; then
  info "installing LazyVim and its plugins (this takes a few minutes)"
  # A cold headless sync races Mason on tree-sitter-cli and prints a harmless
  # "Package is already installing" trace. A second pass settles it so the
  # first interactive launch is clean.
  nvim --headless "+Lazy! sync" +qa >/dev/null 2>&1 || true
  nvim --headless "+Lazy! sync" +qa || warn "plugin sync reported an error; run :Lazy inside nvim"
  info "run :LazyHealth inside nvim to check for anything missing"
else
  warn "neovim is not installed; skipping plugin sync"
fi

step "Done"
cat <<'EOM'
Next steps:
  1. bash git_setup.sh          set your git name and email
  2. Open a new terminal        fish is now your shell
  3. Inside tmux: prefix + I    install tmux plugins
  4. nvim :checkhealth          confirm the editor is happy
EOM
