#!/usr/bin/env bash
#
# Writes your git identity to ~/.config/git/config.local, which is included by
# the tracked config but never committed.

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCAL_CONFIG="$XDG_CONFIG_HOME/git/config.local"

mkdir -p "$(dirname "$LOCAL_CONFIG")"

read -r -p "Your full name (as it should appear in commits): " full_name
read -r -p "Your email address (the one on your GitHub account): " email

if [ -z "$full_name" ] || [ -z "$email" ]; then
  echo "Both name and email are required." >&2
  exit 1
fi

git config --file "$LOCAL_CONFIG" user.name "$full_name"
git config --file "$LOCAL_CONFIG" user.email "$email"

echo
echo "Wrote to $LOCAL_CONFIG:"
git config --file "$LOCAL_CONFIG" --list

if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
  echo
  echo "Warning: ~/.gitconfig exists and overrides ~/.config/git/config." >&2
  echo "Remove or merge it for these settings to take effect." >&2
fi
