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

  # Back up anything real that is in the way, without ever overwriting an
  # earlier backup — a second run with a different file in the way would
  # otherwise silently destroy the first one.
  if [ -e "$dest" ] || [ -L "$dest" ]; then
    if [ -L "$dest" ]; then
      rm "$dest"
    else
      backup="$dest.backup"
      n=1
      while [ -e "$backup" ] || [ -L "$backup" ]; do
        backup="$dest.backup.$n"
        n=$((n + 1))
      done
      mv "$dest" "$backup"
      warn "moved existing $dest to $backup"
    fi
  fi

  ln -s "$src" "$dest"
  info "linked $dest"
}

#
# 0. Prerequisites
#
step "Prerequisites"
if [ "$(uname)" = "Darwin" ]; then
  # Homebrew, git and anything that compiles need the Command Line Tools. On a
  # brand new Mac they are absent and the failure further down is cryptic.
  if ! xcode-select -p >/dev/null 2>&1; then
    error "Xcode Command Line Tools are not installed."
    error "Run this, let it finish, then run install.sh again:"
    error ""
    error "    xcode-select --install"
    exit 1
  fi
  info "Xcode Command Line Tools present"
fi

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
  brew update || warn "brew update failed; continuing with what is installed"
  # Non-fatal on purpose: a single unavailable package must not abort the run
  # before anything is linked. Missing tools are reported, configs still land.
  brew bundle --file="$DOTFILES/Brewfile" \
    || warn "some Brewfile entries failed; see above. Continuing so configs still link."
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

# git cannot expand $XDG_CONFIG_HOME in a config value, so the tracked file has
# to hardcode ~/.config. Write the resolved paths into config.local, which the
# include at the bottom of that file lets win.
git config --file "$XDG_CONFIG_HOME/git/config.local" \
  core.excludesfile "$XDG_CONFIG_HOME/git/gitignore"
git config --file "$XDG_CONFIG_HOME/git/config.local" \
  commit.template "$XDG_CONFIG_HOME/git/gitmessage"
git config --file "$XDG_CONFIG_HOME/git/config.local" \
  gpg.ssh.allowedSignersFile "$XDG_CONFIG_HOME/git/allowed_signers"
info "wrote resolved git paths to $XDG_CONFIG_HOME/git/config.local"

if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
  warn "$HOME/.gitconfig exists and takes precedence over the config linked above."
  warn "Merge anything you still need out of it, then remove it."
fi

# ssh. The directory must be 0700 and ControlPath needs its parent to exist;
# ssh creates neither.
mkdir -p "$HOME/.ssh/control"
chmod 700 "$HOME/.ssh" "$HOME/.ssh/control"
link "config/ssh/config" "$HOME/.ssh/config"

# mise
link "config/mise/config.toml" "$XDG_CONFIG_HOME/mise/config.toml"

# ruby
link "gemrc" "$HOME/.gemrc"
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
      -o "$fisher_fn" || warn "could not download fisher; skipping fish plugins"
  fi
  if [ -e "$fisher_fn" ]; then
    fish -c "source $fisher_fn && fisher update" || warn "fisher update failed; run it yourself later"
  fi
else
  warn "fish is not installed; skipping plugin installation"
fi

#
# 4. Language runtimes
#
step "Language runtimes"
if command -v mise >/dev/null 2>&1; then
  # No plugins to add: every runtime in config/mise/config.toml is a mise core
  # tool. Installing them is left to you — Ruby compiles from source and that is
  # not something an installer should start unannounced.
  info "run 'mise install' to build the runtimes in ~/.config/mise/config.toml"
  info "then 'mise doctor' to check the setup"
else
  warn "mise is not installed; skipping runtime setup"
fi

#
# 5. tmux plugin manager
#
step "tmux plugins"
TPM_DIR="$XDG_CONFIG_HOME/tmux/plugins/tpm"
if [ ! -d "$TPM_DIR" ]; then
  if git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM_DIR"; then
    info "installed tpm — press prefix + I inside tmux to fetch the plugins"
  else
    warn "could not clone tpm; tmux plugins will not load until you retry"
  fi
else
  info "tpm already installed"
fi

#
# 6. Default shell
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
else
  error "fish is not installed, so the login shell was left alone."
  error "brew bundle above must have failed — scroll up for the reason."
fi

#
# 7. Neovim
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

#
# 8. Check what actually landed
#
step "Check"
problems=0

fish_bin="$(command -v fish || true)"
if [ -n "$fish_bin" ]; then
  info "fish            $fish_bin"
else
  error "fish            NOT INSTALLED"
  problems=$((problems + 1))
fi

# $SHELL reflects the shell that started this script, not the account setting,
# so ask the system what the login shell actually is.
# id -un rather than $USER: the latter is unset in some environments and
# `set -u` would abort the whole run here, at the very end.
me="$(id -un)"
if [ "$(uname)" = "Darwin" ]; then
  login_shell="$(dscl . -read "/Users/$me" UserShell 2>/dev/null | awk '{print $2}')"
else
  login_shell="$(getent passwd "$me" 2>/dev/null | cut -d: -f7)"
fi

if [ -n "$fish_bin" ] && [ "$login_shell" = "$fish_bin" ]; then
  info "login shell     $login_shell"
else
  error "login shell     ${login_shell:-unknown} (expected fish)"
  if [ -n "$fish_bin" ]; then
    error "                fix with: chsh -s $fish_bin"
  fi
  problems=$((problems + 1))
fi

for tool in starship mise nvim tmux git; do
  if command -v "$tool" >/dev/null 2>&1; then
    info "$(printf '%-15s' "$tool")$(command -v "$tool")"
  else
    error "$(printf '%-15s' "$tool")NOT INSTALLED"
    problems=$((problems + 1))
  fi
done

if [ -L "$XDG_CONFIG_HOME/fish/config.fish" ]; then
  info "fish config     linked"
else
  error "fish config     NOT LINKED"
  problems=$((problems + 1))
fi

step "Done"
if [ "$problems" -gt 0 ]; then
  warn "$problems problem(s) above. Until they are fixed your terminal will not"
  warn "look right — starship is started from config.fish, so if the shell is"
  warn "not fish you get neither."
  echo
fi

cat <<'EOM'
Next steps:
  1. bash git_setup.sh          set your git name and email
  2. Open a new terminal        fish is now your shell
  3. mise install               install the runtimes (Ruby compiles)
  4. Inside tmux: prefix + I    install tmux plugins
  5. nvim :LazyHealth           confirm the editor is happy

If a new terminal still is not fish, check your terminal app's own setting:
  Terminal.app  Settings > General > "Shells open with"
  iTerm2        Settings > Profiles > General > Command
  Ghostty       the `command` option in your config
Any of those override the login shell.
EOM
