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

# `|| true` so EOF on a closed stdin falls through to the validation below
# rather than aborting under `set -e`.
read -r -p "Your full name (as it should appear in commits): " full_name || true
read -r -p "Your email address (the one on your GitHub account): " email || true

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
key_is_new=no
for candidate in "$HOME/.ssh/id_ed25519.pub" "$HOME/.ssh/id_ecdsa.pub" "$HOME/.ssh/id_rsa.pub"; do
  if [ -f "$candidate" ]; then
    signing_key="$candidate"
    break
  fi
done

if [ -z "$signing_key" ]; then
  echo
  echo "No SSH key found in ~/.ssh. You need one to push to GitHub and to sign"
  echo "commits."
  make_key=""
  read -r -p "Generate an ed25519 key now? [Y/n] " make_key || make_key="n"
  case "${make_key:-y}" in
    [Nn]*)
      echo "Skipped. Run 'ssh-keygen -t ed25519 -C \"$email\"' later, then re-run"
      echo "this script to enable signing."
      ;;
    *)
      mkdir -p "$HOME/.ssh"
      chmod 700 "$HOME/.ssh"
      # Passphrase is prompted interactively, which is what you want.
      ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519"
      signing_key="$HOME/.ssh/id_ed25519.pub"
      key_is_new=yes

      echo
      echo "Your public key:"
      echo
      cat "$signing_key"
      echo
      echo "Add it to GitHub twice — authentication and signing are separate"
      echo "entries there, and you want both:"
      echo "    https://github.com/settings/ssh/new"
      echo
      ;;
  esac
fi

if [ -n "$signing_key" ]; then
  echo
  reply=""
  read -r -p "Sign commits with $signing_key? [Y/n] " reply || reply="n"
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
      if [ "$key_is_new" = "yes" ]; then
        echo "Commit signing is on."
      else
        echo "Commit signing is on. If you have not already, add this key to"
        echo "GitHub as a *signing* key — a separate entry from the"
        echo "authentication key — at https://github.com/settings/ssh/new"
      fi
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
