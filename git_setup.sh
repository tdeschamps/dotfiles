#!/usr/bin/env bash
#
# Writes your git identity — and, if you have an SSH key, commit signing — to
# ~/.config/git/config.local, which the tracked config includes but never
# commits. Safe to re-run.

set -euo pipefail

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
LOCAL_CONFIG="$XDG_CONFIG_HOME/git/config.local"
ALLOWED_SIGNERS="$XDG_CONFIG_HOME/git/allowed_signers"

mkdir -p "$(dirname "$LOCAL_CONFIG")"

read -r -p "Your full name (as it should appear in commits): " full_name
read -r -p "Your email address (the one on your GitHub account): " email

if [ -z "$full_name" ] || [ -z "$email" ]; then
  echo "Both name and email are required." >&2
  exit 1
fi

git config --file "$LOCAL_CONFIG" user.name "$full_name"
git config --file "$LOCAL_CONFIG" user.email "$email"

#
# Commit signing
#
# Preferred key first; whichever exists is offered.
signing_key=""
for candidate in "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_ecdsa.pub" "$HOME/.ssh/id_rsa.pub"; do
  if [ -f "$candidate" ]; then
    signing_key="$candidate"
    break
  fi
done

if [ -z "$signing_key" ]; then
  echo
  echo "No SSH public key found in ~/.ssh, so commit signing was not enabled."
  echo "Create one and re-run this script to turn it on:"
  echo
  echo "    ssh-keygen -t ed25519 -C \"$email\""
  echo
else
  echo
  read -r -p "Sign commits with $signing_key? [Y/n] " reply
  case "${reply:-y}" in
    [Nn]*)
      echo "Skipping commit signing."
      ;;
    *)
      git config --file "$LOCAL_CONFIG" user.signingkey "$signing_key"
      git config --file "$LOCAL_CONFIG" commit.gpgsign true
      git config --file "$LOCAL_CONFIG" tag.gpgsign true

      # allowed_signers lets `git log --show-signature` verify your own commits.
      touch "$ALLOWED_SIGNERS"
      entry="$email namespaces=\"git\" $(cut -d' ' -f1,2 "$signing_key")"
      if ! grep -qxF "$entry" "$ALLOWED_SIGNERS"; then
        echo "$entry" >> "$ALLOWED_SIGNERS"
        echo "Added your key to $ALLOWED_SIGNERS"
      fi

      echo
      echo "Commit signing is on. Add the same key to GitHub as a *signing* key"
      echo "(separate from the authentication key) at:"
      echo "    https://github.com/settings/ssh/new"
      ;;
  esac
fi

echo
echo "Wrote to $LOCAL_CONFIG:"
git config --file "$LOCAL_CONFIG" --list

if [ -f "$HOME/.gitconfig" ] && [ ! -L "$HOME/.gitconfig" ]; then
  echo
  echo "Warning: $HOME/.gitconfig exists and overrides $XDG_CONFIG_HOME/git/config." >&2
  echo "Remove or merge it for these settings to take effect." >&2
fi
